# coding: utf-8
class Project < ActiveRecord::Base
  include I18n::Alchemy
  PUBLISHED_STATES = ['online', 'waiting_funds', 'successful', 'failed']
  HEADLINE_MAXLENGTH = 100
  NAME_MAXLENGTH = 50

  include Statesman::Adapters::ActiveRecordQueries
  include PgSearch

  include Shared::Queued

  include Project::BaseValidator
  include Project::AllOrNothingStateValidator
  include Project::VideoHandler
  include Project::CustomValidators
  include Project::ErrorGroups
  include Project::FlexibleHandler

  has_notifications

  mount_uploader :uploaded_image, ProjectUploader

  delegate  :display_online_date, :display_card_status, :display_status, :progress,
            :display_image, :display_expires_at, :remaining_text, :time_to_go,
            :display_pledged, :display_pledged_with_cents, :display_goal, :remaining_days, :progress_bar,
            :status_flag, :state_warning_template, :display_card_class, :display_errors, to: :decorator

  belongs_to :user
  belongs_to :category
  belongs_to :city
  belongs_to :origin
  has_one :flexible_project
  has_one :project_total
  has_one :account, class_name: "ProjectAccount", inverse_of: :project
  has_many :taggings
  has_many :tags, through: :taggings
  has_many :rewards
  has_many :contributions
  has_many :contribution_details
  has_many :payments, through: :contributions
  has_many :posts, class_name: "ProjectPost", inverse_of: :project
  has_many :budgets, class_name: "ProjectBudget", inverse_of: :project
  has_many :unsubscribes
  has_many :reminders, class_name: 'ProjectReminder', inverse_of: :project

  has_many :project_transitions, autosave: false

  accepts_nested_attributes_for :rewards, allow_destroy: true
  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :account
  accepts_nested_attributes_for :posts, allow_destroy: true, reject_if: ->(x) { x[:title].blank? || x[:comment_html].blank? }
  accepts_nested_attributes_for :budgets, allow_destroy: true, reject_if: ->(x) { x[:name].blank? || x[:value].blank? }

  pg_search_scope :search_tsearch,
    against: "full_text_index",
    using: {
      tsearch: {
        dictionary: "portuguese",
        tsvector_column: "full_text_index"
      }
    },
    ignoring: :accents

  pg_search_scope :search_trm,
    against: "name",
    using: :trigram,
    ignoring: :accents

  def self.pg_search term
    search_tsearch(term).presence || search_trm(term)
  end

  # With state scopes
  scope :maybe_flex, -> {
    joins("LEFT JOIN flexible_projects fp on fp.project_id = projects.id")
  }
  scope :with_state, -> (state) {
      maybe_flex.where("coalesce(fp.state, projects.state) in (?)", state)
  }
  scope :without_state, -> (state) {
      maybe_flex.where("coalesce(fp.state, projects.state) not in (?)", state)
  }

  scope :with_states, -> (state) { with_state(state) }
  scope :without_states, -> (state) { without_state(state) }

  # Used to simplify a has_scope
  scope :successful, ->{ with_state('successful') }
  scope :with_project_totals, -> { joins('LEFT OUTER JOIN project_totals ON project_totals.project_id = projects.id') }

  scope :by_progress, ->(progress) { joins(:project_total).where("project_totals.pledged >= projects.goal*?", progress.to_i/100.to_f) }
  scope :by_user_email, ->(email) { joins(:user).where("users.email = ?", email) }
  scope :by_id, ->(id) { where(id: id) }
  scope :by_goal, ->(goal) { where(goal: goal) }
  scope :by_category_id, ->(id) { where(category_id: id) }
  scope :by_online_date, ->(online_date) { where(online_date: Time.zone.parse( online_date ).. Time.zone.parse( online_date ).end_of_day) }
  scope :by_expires_at, ->(expires_at) { where(expires_at: Time.zone.parse( expires_at ).. Time.zone.parse( expires_at ).end_of_day) }
  scope :by_updated_at, ->(updated_at) { where(updated_at: Time.zone.parse( updated_at ).. Time.zone.parse( updated_at ).end_of_day) }
  scope :by_permalink, ->(p) { without_state('deleted').where("lower(permalink) = lower(?)", p) }
  scope :recommended, -> { where(recommended: true) }
  scope :in_funding, -> { not_expired.with_states(['online']) }
  scope :name_contains, ->(term) { where("unaccent(upper(name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :user_name_contains, ->(term) { joins(:user).where("unaccent(upper(users.name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :to_finish, ->{ expired.with_states(['online', 'waiting_funds']) }
  scope :visible, -> { without_states(['draft', 'rejected', 'deleted', 'in_analysis', 'approved']) }
  scope :financial, -> { with_states(['online', 'successful', 'waiting_funds']).where(expires_at: 15.days.ago.. Time.current) }
  scope :expired, -> { where("projects.is_expired") }
  scope :not_expired, -> { where("not projects.is_expired") }
  scope :expiring, -> { not_expired.where(expires_at: Time.current.. 2.weeks.from_now) }
  scope :not_expiring, -> { not_expired.where.not(expires_at: Time.current.. 2.weeks.from_now) }
  scope :recent, -> { where(online_date: 5.days.ago.. Time.current) }
  scope :ordered, -> { order(created_at: :desc)}
  scope :order_status, ->{ maybe_flex.order("
                                     CASE coalesce(fp.state, projects.state)
                                     WHEN 'online' THEN 1
                                     WHEN 'waiting_funds' THEN 2
                                     WHEN 'successful' THEN 3
                                     WHEN 'failed' THEN 4
                                     END ASC")}
  scope :most_recent_first, ->{ order("projects.online_date DESC, projects.created_at DESC") }
  scope :order_for_admin, -> {
    maybe_flex.reorder("
            CASE coalesce(fp.state, projects.state)
            WHEN 'in_analysis' THEN 1
            WHEN 'waiting_funds' THEN 2
            WHEN 'successful' THEN 3
            WHEN 'failed' THEN 4
            END ASC, projects.online_date DESC, projects.created_at DESC")
  }

  scope :with_contributions_confirmed_last_day, -> {
    joins(:contributions).merge(Contribution.confirmed_last_day).uniq
  }

  scope :of_current_week, -> { where(online_date: 7.days.ago.. Time.current) }

  attr_accessor :accepted_terms

  validates_acceptance_of :accepted_terms, on: :create
  ##validation for all states
  validates_presence_of :name, :user, :category
  validates_length_of :headline, maximum: HEADLINE_MAXLENGTH
  validates_numericality_of :online_days, less_than_or_equal_to: 60, greater_than: 0,
    if: ->(p){ p.online_days.present? && ( p.online_days_was.nil? || p.online_days_was <= 60 ) }
  validates_numericality_of :goal, greater_than: 9, allow_blank: true
  validates_uniqueness_of :permalink, case_sensitive: false
  validates_format_of :permalink, with: /\A(\w|-)*\Z/
  validates_presence_of :permalink, allow_nil: true


  [:between_created_at, :between_expires_at, :between_online_date, :between_updated_at].each do |name|
    define_singleton_method name do |starts_at, ends_at|
      return all unless starts_at.present? && ends_at.present?
      field = name.to_s.gsub('between_','')
      where(field => Time.zone.parse( starts_at ).. Time.zone.parse( ends_at ).end_of_day)
    end
  end

  def self.goal_between(starts_at, ends_at)
    where("goal BETWEEN ? AND ?", starts_at, ends_at)
  end

  def self.order_by(sort_field)
    return self.all unless sort_field =~ /^\w+(\.\w+)?\s(desc|asc)$/i
    order(sort_field)
  end

  def has_blank_service_fee?
    payments.with_state(:paid).where("NULLIF(gateway_fee, 0) IS NULL").present?
  end

  def can_show_account_link?
    ['online', 'waiting_funds', 'successful', 'approved'].include? state
  end

  def can_show_preview_link?
    !published?
  end

  def subscribed_users
    User.subscribed_to_posts.subscribed_to_project(self.id)
  end

  def decorator
    @decorator ||= ProjectDecorator.new(self)
  end

  def pledged
    @pledged ||= project_total.try(:pledged).to_f
  end

  def total_contributions
    @total_contributions ||= project_total.try(:total_contributions).to_i
  end

  def total_contributors
    @total_contributors ||= project_total.try(:total_contributors).to_i
  end

  def total_payment_service_fee
    project_total.try(:total_payment_service_fee).to_f
  end

  def selected_rewards
    rewards.sort_asc.where(id: contributions.where('contributions.is_confirmed').map(&:reward_id))
  end

  def accept_contributions?
    online? && !expired?
  end

  def reached_goal?
    pledged >= goal
  end

  def expired?
    expires_at && pluck_from_database("is_expired")
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
      self.user,
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

  def delete_from_reminder_queue(user_id)
    self.notifications.where(template_name: 'reminder', user_id: user_id).destroy_all
  end

  def published?
    pluck_from_database("is_published")
  end

  def expires_fragments *fragments
    base = ActionController::Base.new
    fragments.each do |fragment|
      base.expire_fragment([fragment, id])
    end
  end

  def to_analytics
    {
      id: self.id,
      permalink: self.permalink,
      total_contributions: self.total_contributions,
      pledged: self.pledged,
      project_state: self.state,
      category: self.category.name_pt,
      project_goal: self.goal,
      project_online_date: self.online_date,
      project_expires_at: self.expires_at,
      project_address_city: self.account.try(:address_city),
      project_address_state: self.account.try(:address_state),
      account_entity_type: self.account.try(:entity_type)
    }
  end

  def to_analytics_json
    to_analytics.to_json
  end

  def mode
    # aon is the default value because now we always need a mode for a project
    # After the next refactoring (when we extract aon to another table) this will
    # no longer be necessary
    pluck_from_database("mode") || 'aon'
  end

  def pluck_from_database attribute
    Project.where(id: self.id).pluck("projects.#{attribute}").first
  end

  def open_for_contributions?
    pluck_from_database(:open_for_contributions)
  end

  def all_tags=(names)
    self.tags = names.split(',').map do |name|
      Tag.find_or_create_by(slug: name.parameterize) do |tag|
        tag.name = name.strip
      end
    end
  end

  def all_tags
    tags.map(&:name).join(", ")
  end

  def update_expires_at
    if self.online_days.present? && self.online_date.present?
      self.expires_at = (self.online_date + self.online_days.days).end_of_day
    end
  end

  # State machine delegation methods
  delegate :push_to_draft, :reject, :push_to_online, :finish,
    :send_to_analysis, :approve, :push_to_trash, :can_transition_to?,
    :transition_to, :can_reject?, :can_push_to_trash?,
    :can_push_to_online?, :can_push_to_draft?, :can_approve?, to: :state_machine

  # Get all states names from AonProjectMachine
  # Used in some legacy parts of the admin
  # @TODO: Remove this method
  def self.state_names
    AonProjectMachine.states.map(&:to_sym)
  end

  # Init all or nothing machine
  def state_machine
    @state_machine ||= AonProjectMachine.new(self, {
      transition_class: ProjectTransition
    })
  end

  %w(
    draft rejected online successful waiting_funds
    deleted in_analysis approved failed
  ).each do |st|
    define_method "#{st}?" do
      if self.state.nil?
        self.state_machine.current_state == st
      else
        self.state == st
      end
    end
  end
end
