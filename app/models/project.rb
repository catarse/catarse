# coding: utf-8
# frozen_string_literal: true

class Project < ApplicationRecord
  include I18n::Alchemy
  PUBLISHED_STATES = %w[online waiting_funds successful failed].freeze
  HEADLINE_MAXLENGTH = 100
  NAME_MAXLENGTH = 50


  include Statesman::Adapters::ActiveRecordQueries[
    transition_class: ProjectTransition,
    initial_state: :draft
  ]

  include PgSearch::Model

  include Shared::Queued
  include Shared::CommonWrapper

  include Project::BaseValidator
  include Project::AllOrNothingStateValidator
  include Project::VideoHandler
  include Project::CustomValidators

  has_notifications

  mount_uploader :uploaded_image, ProjectUploader

  delegate  :display_card_status, :display_status, :progress,
            :display_image, :display_expires_at, :time_to_go, :elapsed_time,
            :display_pledged, :display_pledged_with_cents, :display_goal, :progress_bar,
            :status_flag, to: :decorator

  before_save :set_adult_content_tag

  self.inheritance_column = 'mode'
  belongs_to :user
  belongs_to :category
  belongs_to :city, optional: true
  belongs_to :origin, optional: true
  has_one :balance_transfer, inverse_of: :project
  has_one :project_cancelation
  has_one :project_total
  has_one :project_fiscal_data
  has_one :project_score_storage
  has_one :project_metric_storage
  has_many :balance_transactions
  has_many :taggings
  has_many :goals, foreign_key: :project_id, inverse_of: :project
  has_many :tags, through: :taggings
  has_many :public_tags, through: :taggings
  has_many :rewards, inverse_of: :project
  has_many :contributions
  has_many :project_errors
  has_many :contribution_details
  has_many :payments, through: :contributions
  has_many :posts, class_name: 'ProjectPost', inverse_of: :project
  has_many :budgets, class_name: 'ProjectBudget', inverse_of: :project
  has_many :unsubscribes
  has_many :reminders, class_name: 'ProjectReminder', inverse_of: :project
  has_many :project_report_exports, dependent: :destroy
  has_many :project_fiscals

  has_many :project_transitions, autosave: false

  has_many :integrations, class_name: 'ProjectIntegration', inverse_of: :project

  accepts_nested_attributes_for :integrations, allow_destroy: true
  accepts_nested_attributes_for :rewards, allow_destroy: true
  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :posts, allow_destroy: true, reject_if: ->(x) { x[:title].blank? || x[:comment_html].blank? }
  accepts_nested_attributes_for :budgets, allow_destroy: true, reject_if: ->(x) { x[:name].blank? || x[:value].blank? }

  pg_search_scope :search_tsearch,
                  against: 'full_text_index',
                  using: {
                    tsearch: {
                      dictionary: 'portuguese',
                      tsvector_column: 'full_text_index'
                    }
                  },
                  ignoring: :accents

  pg_search_scope :search_trm,
                  against: 'name',
                  using: :trigram,
                  ignoring: :accents

  after_commit :start_metric_storage_worker, on: :create

  def start_metric_storage_worker
    ProjectMetricStorageRefreshWorker.perform_async(id)
  end

  def self.pg_search(term)
    search_tsearch(term).presence || search_trm(term)
  end

  # With state scopes
  scope :with_state, ->(state) {
    where('projects.state in (?)', state)
  }
  scope :without_state, ->(state) {
    where('projects.state not in (?)', state)
  }

  # This scope is used only on this model
  scope :between_dates, ->(column, start_at, end_at) {
    where(
      "projects.#{column} between :start and :end",
      {
        start: start_at,
        end: end_at
      }
    )
  }

  scope :with_states, ->(state) { with_state(state) }
  scope :without_states, ->(state) { without_state(state) }

  # Used to simplify a has_scope
  scope :successful, -> { with_state('successful') }
  scope :with_project_totals, -> { joins('LEFT OUTER JOIN project_totals ON project_totals.project_id = projects.id') }

  scope :by_progress, ->(progress) { joins(:project_total).where('project_totals.pledged >= projects.goal*?', progress.to_i / 100.to_f) }
  scope :by_user_email, ->(email) { joins(:user).where('users.email = ?', email) }
  scope :by_id, ->(id) { where(id: id) }
  scope :by_goal, ->(goal) { where(goal: goal) }
  scope :by_category_id, ->(id) { where(category_id: id) }

  scope :by_online_date, ->(online_date) {
    between_dates('online_at',
                  Time.zone.parse(online_date),
                  Time.zone.parse(online_date).end_of_day)
  }

  scope :by_expires_at, ->(expires_at) {
    between_dates('expires_at',
                  Time.zone.parse(expires_at),
                  Time.zone.parse(expires_at).end_of_day)
  }

  scope :by_updated_at, ->(updated_at) {
    between_dates('updated_at',
                  Time.zone.parse(updated_at),
                  Time.zone.parse(updated_at).end_of_day)
  }

  scope :recent, -> {
    between_dates('online_at', 5.days.ago, Time.current)
  }

  scope :expiring, -> {
    not_expired.between_dates('expires_at', Time.current, 2.weeks.from_now)
  }

  scope :not_expiring, -> {
    not_expired.where.not(expires_at: Time.current..2.weeks.from_now)
  }

  scope :financial, -> {
    with_states(%w[online successful waiting_funds])
      .between_dates('expires_at', 15.days.ago, Time.current)
  }

  scope :of_current_week, -> {
    between_dates('online_at', 7.days.ago, Time.current)
  }

  scope :by_permalink, ->(p) { without_state('deleted').where('lower(permalink) = lower(?)', p) }
  scope :recommended, -> { where(recommended: true) }
  scope :in_funding, -> { not_expired.with_states(['online']) }
  scope :name_contains, ->(term) { where("unaccent(upper(name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :user_name_contains, ->(term) { joins(:user).where("unaccent(upper(users.name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :to_finish, -> { expired.where(skip_finish: false).with_states(%w[online waiting_funds]) }
  scope :visible, -> { without_states(%w[draft rejected deleted]) }
  scope :expired, -> { where('projects.is_expired') }
  scope :not_expired, -> { where('not projects.is_expired') }
  scope :ordered, -> { order(created_at: :desc) }
  scope :update_ordered, -> { order('updated_at DESC, created_at DESC') }
  scope :order_status, -> {
    order("
                CASE projects.state
                WHEN 'online' THEN 1
                WHEN 'waiting_funds' THEN 2
                WHEN 'successful' THEN 3
                WHEN 'failed' THEN 4
                END ASC")
  }
  scope :most_recent_first, -> { order('projects.id DESC') }
  scope :order_for_admin, -> {
    reorder("
            CASE projects.state
            WHEN 'waiting_funds' THEN 2
            WHEN 'successful' THEN 3
            WHEN 'failed' THEN 4
            END ASC, projects.online_at DESC, projects.created_at DESC")
  }

  scope :with_contributions_confirmed_last_day, -> {
    joins(:contributions).merge(Contribution.confirmed_last_day).uniq
  }

  scope :with_deliveries_approaching, -> {
    successful.where("exists(
        select true from rewards r
        where r.project_id = projects.id
        AND (deliver_at > now())
        AND (deliver_at <= now() + '1 month'::interval))")
  }

  scope :with_late_deliveries, -> {
    successful.where("projects.expires_at > now() - '1 year'::interval AND exists(
        select true from rewards r
        where r.project_id = projects.id
        AND (deliver_at + '1 week'::interval < now())
        ) AND NOT EXISTS (
        select true from contributions c
        where c.project_id = projects.id
        and (c.reward_sent_at is not null OR c.reward_received_at is not null)
        )")
  }

  attr_accessor :accepted_terms

  before_validation :sanitize_fields

  validates_acceptance_of :accepted_terms, on: :create
  # #validation for all states
  validates_presence_of :name, :user, :category, :service_fee
  validates_length_of :headline, maximum: HEADLINE_MAXLENGTH
  validates_numericality_of :goal, greater_than: 9, allow_blank: true
  validates_numericality_of :service_fee, greater_than: 0, less_than_or_equal_to: 1
  validates_uniqueness_of :permalink, case_sensitive: false
  validates_format_of :permalink, with: /\A(\w|-)*\Z/
  validates_presence_of :permalink, allow_nil: true

  %i[between_created_at between_expires_at between_online_at between_updated_at].each do |name|
    define_singleton_method name do |starts_at, ends_at|
      return all unless starts_at.present? && ends_at.present?
      field = name.to_s.gsub('between_', '')
      where(field => Time.zone.parse(starts_at)..Time.zone.parse(ends_at).end_of_day)
    end
  end

  def self.find_sti_class(type_name)
    case type_name
    when 'flex'
      FlexibleProject
    when 'sub'
      SubscriptionProject
    else
      Project
    end
  end

  def self.goal_between(starts_at, ends_at)
    where('goal BETWEEN ? AND ?', starts_at, ends_at)
  end

  def self.order_by(sort_field)
    return all unless sort_field =~ /^\w+(\.\w+)?\s(desc|asc)$/i
    order(sort_field)
  end

  def has_recent_invalid_finish_notification?
    notifications.where(%{
      template_name = 'invalid_finish'
      and created_at > (current_timestamp - '24 hours'::interval)
    }).exists?
  end

  def create_event_to_state
    Rdevent.create(
      user_id: user.id,
      project_id: id,
      event_name: "#{event_mode_prefix}project_#{state}"
    )
  end

  def event_mode_prefix
    if is_supportive?
      'solidaria_'
    elsif is_sub?
      'sub_'
    else
      ''
    end
  end

  def is_supportive?
    supportive_integration.present?
  end

  def supportive_integration
    integrations.where(name: 'SOLIDARITY_SERVICE_FEE')
  end

  def has_blank_service_fee?
    payments.with_state(:paid).where('NULLIF(gateway_fee, 0) IS NULL').present?
  end

  def has_comming_soon_landing_page_integration?
    comming_soon_landing_page_integration.present?
  end

  def comming_soon_landing_page_integration
    integrations.where(name: 'COMING_SOON_LANDING_PAGE').first
  end

  def subscribed_users
    if is_sub?
      User.subscribed_to_posts.subscribed_to_project(common_id)
    else
      User.subscribed_to_posts.contributed_to_project(id)
    end
  end

  def decorator
    @decorator ||= ProjectDecorator.new(self)
  end

  def total_catarse_fee
    total_catarse_fee ||= pluck_from_database('total_catarse_fee')
  end

  def irrf_tax
    irrf_tax ||= pluck_from_database('irrf_tax')
  end

  def pledged
    pledged ||= project_total.try(:pledged).to_f
  end

  def paid_pledged
    paid_pledged ||= project_total.try(:paid_pledged).to_f
  end

  def total_contributions
    @total_contributions ||= project_total.try(:total_contributions).to_i
  end

  def total_contributors
    @total_contributors ||= project_total.try(:total_contributors).to_i
  end

  def total_posts
    @total_posts ||= posts.count
  end

  def total_payment_service_fee
    project_total.try(:total_payment_service_fee).to_f
  end

  def paid_total_payment_service_fee
    project_total.try(:paid_total_payment_service_fee).to_f
  end

  def selected_rewards
    rewards.sort_asc.where(id: contributions.where('contributions.is_confirmed').map(&:reward_id))
  end

  def accept_contributions?
    online? && !expired?
  end

  def reached_goal?
    paid_pledged >= goal
  end

  def expired?
    expires_at && pluck_from_database('is_expired')
  end

  def in_time_to_wait?
    payments.waiting_payment.exists?
  end

  def new_draft_recipient
    User.find_by_email CatarseSettings[:email_projects]
  end

  def notify_owner(template_name, params = {})
    notify_once(
      template_name,
      user,
      self,
      params
    )
  end

  def notify_to_backoffice(template_name, options = {}, backoffice_user = User.find_by(email: CatarseSettings[:email_payments]))
    if backoffice_user
      notify_once(
        template_name,
        backoffice_user,
        self,
        options
      )
    end
  end

  def notify_reminder_of_publish(options = {})
    reminders.each do |reminder|
      notify_once(
        'project_coming_soon_published',
        reminder.user,
        self,
        options
      )
    end
  end

  def delete_from_reminder_queue(user_id)
    notifications.where(template_name: 'reminder', user_id: user_id).destroy_all
  end

  def published?
    pluck_from_database('is_published')
  end

  def expires_fragments(*fragments)
    base = ActionController::Base.new
    fragments.each do |fragment|
      base.expire_fragment([fragment, id])
    end
  end

  def to_analytics
    {
      id: id,
      permalink: permalink,
      total_contributions: total_contributions,
      pledged: pledged,
      project_state: state,
      category: category.name_pt,
      project_goal: goal,
      project_online_date: online_at,
      project_expires_at: expires_at,
      project_address_city: city.try(:name) || user.try(:address_city),
      project_address_state: city.try(:state).try(:acronym) || user.try(:address_state),
      account_entity_type: user.try(:decorator).try(:entity_type)
    }
  end

  def to_js(current_user)
    {
      about_html: about_html,
      budget: budget,
      address: {
        city: city.try(:name) || user.try(:address_city),
        state_acronym: city.try(:state).try(:acronym) || user.try(:address_state),
        state: city.try(:state).try(:acronym) || user.try(:address_state)
      },
      category_id: category.id,
      category_name: category.name_pt,
      elapsed_time: {
        total: elapsed_time[:time],
        unit: elapsed_time[:unit]
      },
      remaining_time: {
        total: time_to_go[:time],
        unit: time_to_go[:unit]
      },
      expires_at: expires_at,
      goal: goal.to_i,
      headline: headline,
      project_id: id,
      project_user_id: user_id,
      user: {
        id: user.id,
        name: user.name,
        public_name: user.public_name
      },
      permalink: permalink,
      total_contributions: total_contributions,
      total_contributors: total_contributors,
      posts_count: total_posts,
      pledged: pledged,
      project_state: state,
      category: category.name_pt,
      online_date: online_at,
      online_days: online_days,
      name: name,
      original_image: display_image('project_thumb_large'),
      progress: progress,
      thumb_image: display_image,
      video_cover_image: video_thumbnail,
      video_url: video_url,
      video_embed_url: video_embed_url,
      mode: mode,
      open_for_contributions: open_for_contributions?,
      zone_expires_at: expires_at,
      zone_online_date: online_at,
      state: state,
      is_published: published?,
      in_reminder: is_in_reminder?(current_user),
      is_admin_role: current_user.try(:admin?) || false,
      is_owner_or_admin: (current_user && (current_user == user || current_user.admin?) ? true : false)
    }
  end

  def to_analytics_json
    to_analytics.to_json
  end

  def to_js_json(current_user)
    to_js(current_user).to_json
  end

  def pluck_from_database(attribute)
    Project.where(id: id).pluck(Arel.sql("projects.#{attribute}")).first
  end

  def open_for_contributions?
    pluck_from_database(:open_for_contributions)
  end

  def direct_url
    @direct_url ||= Rails.application.routes.url_helpers.project_by_slug_url(permalink: permalink, locale: nil)
  end

  def all_public_tags=(names)
    self.public_tags = names.split(',').map do |name|
      name.split(' ').map do |n|
        PublicTag.find_or_create_by(slug: n.parameterize) do |tag|
          tag.name = n.strip.capitalize
        end
      end
    end.flatten
  end

  def all_public_tags
    public_tags.map(&:name).join(', ')
  end

  def all_tags=(names)
    self.tags = names.split(',').map do |name|
      Tag.find_or_create_by(slug: name.parameterize) do |tag|
        tag.name = name.strip
      end
    end
  end

  def all_tags
    tags.map(&:name).join(', ')
  end

  def set_adult_content_tag
    return if !should_include_adult_content_tag?
    return if has_adult_content_tag? && content_rating >= 18

    _all_tags = tags.map(&:name)
    if should_include_adult_content_tag?
      _all_tags |= [adult_content_admin_tag]
    else
      _all_tags = _all_tags.reject{|tag| tag == adult_content_admin_tag}
    end

    self.tags = _all_tags.map do |name|
      Tag.find_or_create_by(slug: name.parameterize) do |tag|
        tag.name = name.strip
      end
    end
  end

  def should_include_adult_content_tag?
    content_rating >= 18 && tags.map(&:name).exclude?(adult_content_admin_tag)
  end

  def has_adult_content_tag?
    tags.map(&:name).include?(adult_content_admin_tag)
  end

  def is_flexible?
    mode == 'flex'
  end

  def is_sub?
    mode == 'sub'
  end

  def is_in_reminder?(current_user)
    (current_user ? reminders.where(user_id: current_user.try(:id), project_id: id).exists? : false)
  end

  def update_expires_at
    if online_days.present? && online_at.present?
      self.expires_at = (online_at.in_time_zone + online_days.days).end_of_day
    end
  end

  def all_pledged_kind_transactions
    balance_transactions.where(event_name: %w[successful_project_pledged project_contribution_confirmed_after_finished])
  end

  def successful_pledged_transaction
    balance_transactions.where(event_name: 'successful_project_pledged').last
  end

  def total_amount_tax_included
    pluck_from_database("total_amount_tax_included")
  end

  def can_cancel?
    pluck_from_database("can_cancel")
  end

  def refresh_project_score_storage
    pluck_from_database('refresh_project_score_storage')
  end

  def refresh_project_metric_storage
    pluck_from_database('refresh_project_metric_storage')
  end

  def adult_content_admin_tag
    I18n.t('project.adult_content_admin_tag')
  end

  # State machine delegation methods
  delegate :push_to_draft, :reject, :push_to_online, :fake_push_to_online, :finish, :push_to_trash,
    :can_transition_to?, :transition_to, :can_reject?, :can_push_to_trash?, :can_push_to_online?, :can_push_to_draft?,
    to: :state_machine

  # Get all states names from AonProjectMachine
  # Used in some legacy parts of the admin
  # @TODO: Remove this method
  def self.state_names
    AonProjectMachine.states.map(&:to_sym)
  end

  # Init all or nothing machine
  def state_machine
    @state_machine ||= AonProjectMachine.new(self, { transition_class: ProjectTransition })
  end

  %w[
    draft rejected online successful waiting_funds
    deleted failed
  ].each do |st|
    define_method "#{st}_at" do
      pluck_from_database("#{st}_at")
    end

    define_method "#{st}?" do
      if state.nil?
        state_machine.current_state == st
      else
        state == st
      end
    end
  end

  # common integration

  def common_index
    id_hash = common_id.present? ? {id: common_id} : {}
    {
      external_id: id,
      user_id: user.common_id,
      current_ip: user.current_sign_in_ip,
      name: name,
      status: state,
      permalink: permalink,
      mode: mode,
      service_fee: service_fee,
      about_html: about_html,
      budget_html: budget_html,
      online_days: online_days,
      address: {
        city: city.try(:name),
        state: city.try(:state).try(:acronym)
      }
    }.merge!(id_hash)
  end

  def index_on_common
    unless user.common_id.present?
      user.index_on_common
      user.reload
    end

    common_wrapper.index_project(self) if common_wrapper
  end

  def common_finish!
    unless user.common_id.present?
      user.index_on_common
      user.reload
    end

    common_wrapper.finish_project(self) if common_wrapper
  end

  def sanitize_fields
    self.about_html = SanitizeScriptTag.sanitize(about_html)
    self.budget = SanitizeScriptTag.sanitize(budget)
  end
end
