# coding: utf-8
class Project < ActiveRecord::Base
  include PgSearch

  include Shared::CatarseAutoHtml
  include Shared::StateMachineHelpers
  include Shared::Queued

  include Project::StateMachineHandler
  include Project::VideoHandler
  include Project::CustomValidators
  include Project::RemindersHandler
  include Project::ErrorGroups

  has_notifications

  mount_uploader :uploaded_image, ProjectUploader

  delegate  :display_online_date, :display_status, :progress, :display_progress,
            :display_image, :display_expires_at, :remaining_text, :time_to_go,
            :display_pledged, :display_goal, :remaining_days, :progress_bar,
            :status_flag, :state_warning_template, :display_card_class, :display_errors, to: :decorator

  belongs_to :user
  belongs_to :category
  has_one :project_total
  has_many :rewards
  has_many :contributions
  has_many :posts, class_name: "ProjectPost", inverse_of: :project
  has_many :budgets, class_name: "ProjectBudget", inverse_of: :project
  has_many :unsubscribes

  accepts_nested_attributes_for :rewards, allow_destroy: true, reject_if: -> (x) { x[:description].blank? || x[:minimum_value].blank? }
  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :posts, allow_destroy: true#, reject_if: ->(x) { x[:title].blank? || x[:comment].blank? }
  accepts_nested_attributes_for :budgets, allow_destroy: true, reject_if: ->(x) { x[:name].blank? || x[:value].blank? }

  catarse_auto_html_for field: :about, video_width: 600, video_height: 403

  pg_search_scope :search_on_name,
    against: [[:name, 'A'], [:permalink, 'C'], [:headline, 'B']],
    associated_against: {
      category: [:name_pt, :name_en]
    },
    using: {tsearch: {dictionary: "portuguese"}},
    ignoring: :accents

  pg_search_scope :pg_search, against: [
      [:name, 'A'],
      [:headline, 'B'],
      [:about, 'C']
    ],
    associated_against:  {
      user: [:name, :address_city ],
      category: [:name_pt, :name_en]
    },
    using: {tsearch: {dictionary: "portuguese"}},
    ignoring: :accents

  # Used to simplify a has_scope
  scope :successful, ->{ with_state('successful') }
  scope :with_project_totals, -> { joins('LEFT OUTER JOIN project_totals ON project_totals.project_id = projects.id') }

  scope :by_progress, ->(progress) { joins(:project_total).where("project_totals.pledged >= projects.goal*?", progress.to_i/100.to_f) }
  scope :by_user_email, ->(email) { joins(:user).where("users.email = ?", email) }
  scope :by_id, ->(id) { where(id: id) }
  scope :by_goal, ->(goal) { where(goal: goal) }
  scope :by_category_id, ->(id) { where(category_id: id) }
  scope :by_online_date, ->(online_date) { where("online_date::date = ?", online_date.to_date) }
  scope :by_expires_at, ->(expires_at) { where("projects.expires_at::date = ?", expires_at.to_date) }
  scope :by_updated_at, ->(updated_at) { where("updated_at::date = ?", updated_at.to_date) }
  scope :by_permalink, ->(p) { without_state('deleted').where("lower(permalink) = lower(?)", p) }
  scope :recommended, -> { where(recommended: true) }
  scope :in_funding, -> { not_expired.with_states(['online']) }
  scope :name_contains, ->(term) { where("unaccent(upper(name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :user_name_contains, ->(term) { joins(:user).where("unaccent(upper(users.name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :near_of, ->(address_state) { where("EXISTS(SELECT true FROM users u WHERE u.id = projects.user_id AND lower(u.address_state) = lower(?))", address_state) }
  scope :to_finish, ->{ expired.with_states(['online', 'waiting_funds']) }
  scope :visible, -> { without_states(['draft', 'rejected', 'deleted', 'in_analysis', 'approved']) }
  scope :financial, -> { with_states(['online', 'successful', 'waiting_funds']).where("projects.expires_at > (current_timestamp - '15 days'::interval)") }
  scope :expired, -> { where("projects.expires_at < current_timestamp") }
  scope :not_expired, -> { where("projects.expires_at >= current_timestamp") }
  scope :expiring, -> { not_expired.where("projects.expires_at <= (current_timestamp + interval '2 weeks')") }
  scope :not_expiring, -> { not_expired.where("NOT (projects.expires_at <= (current_timestamp + interval '2 weeks'))") }
  scope :recent, -> { where("(current_timestamp - projects.online_date) <= '5 days'::interval") }
  scope :order_status, ->{ order("
                                     CASE projects.state
                                     WHEN 'online' THEN 1
                                     WHEN 'waiting_funds' THEN 2
                                     WHEN 'successful' THEN 3
                                     WHEN 'failed' THEN 4
                                     END ASC")}
  scope :most_recent_first, ->{ order("projects.online_date DESC, projects.created_at DESC") }
  scope :order_for_admin, -> {
    reorder("
            CASE projects.state
            WHEN 'in_analysis' THEN 1
            WHEN 'waiting_funds' THEN 2
            WHEN 'successful' THEN 3
            WHEN 'failed' THEN 4
            END ASC, projects.online_date DESC, projects.created_at DESC")
  }

  scope :with_contributions_confirmed_today, -> {
    joins(:contributions).merge(Contribution.confirmed_today).uniq
  }

  scope :expiring_in_less_of, ->(time) {
    with_state('online').where("(projects.expires_at - current_date) <= ?", time)
  }

  scope :of_current_week, -> {
    where("
      projects.online_date AT TIME ZONE '#{Time.zone.tzinfo.name}' >= (current_timestamp AT TIME ZONE '#{Time.zone.tzinfo.name}' - '7 days'::interval)
    ")
  }

  scope :using_pagarme, -> (permalinks) {
    where("projects.permalink in (:permalinks) OR
           projects.online_date::date  AT TIME ZONE '#{Time.zone.tzinfo.name}' >= '2014-11-10'::date AT TIME ZONE '#{Time.zone.tzinfo.name}'",
          { permalinks: permalinks })
  }

  scope :not_using_pagarme, -> {
    where("projects.permalink not in (:permalinks) AND projects.online_date::date AT TIME ZONE '#{Time.zone.tzinfo.name}' < '2014-11-10'::date AT TIME ZONE '#{Time.zone.tzinfo.name}'",
          { permalinks: (CatarseSettings[:projects_enabled_to_use_pagarme].split(',').map(&:strip) rescue []) })
  }

  attr_accessor :accepted_terms

  # Draft state validtions
  validates_acceptance_of :accepted_terms, on: :create
  validates_presence_of :name, :user, :category, :permalink
  validates_length_of :headline, maximum: 140
  validates_numericality_of :online_days, less_than_or_equal_to: 60, greater_than: 0, if: ->(p){ p.online_days.present? }
  validates_numericality_of :goal, greater_than: 9, allow_blank: true
  validates_uniqueness_of :permalink, case_sensitive: false
  validates_format_of :permalink, with: /(\w|-)*/

  validates_with StateValidator

  [:between_created_at, :between_expires_at, :between_online_date, :between_updated_at].each do |name|
    define_singleton_method name do |starts_at, ends_at|
      between_dates name.to_s.gsub('between_',''), starts_at, ends_at
    end
  end

  def self.with_payment_engine(payment_engine_name)
    case payment_engine_name
    when 'pagarme' then
      self.enabled_to_use_pagarme
    when 'moip' then
      self.not_using_pagarme
    else
      self
    end
  end

  def self.send_verify_moip_account_notification
    expiring_in_less_of('7 days').find_each do |project|
      unless project.using_pagarme?
        project.notify_owner(:verify_moip_account, { from_email: CatarseSettings[:email_payments]})
      end
    end
  end

  def self.goal_between(starts_at, ends_at)
    where("goal BETWEEN ? AND ?", starts_at, ends_at)
  end

  def self.order_by(sort_field)
    return self.all unless sort_field =~ /^\w+(\.\w+)?\s(desc|asc)$/i
    order(sort_field)
  end

  def self.enabled_to_use_pagarme
    begin
      permalinks = CatarseSettings[:projects_enabled_to_use_pagarme].split(',').map(&:strip)
    rescue
      permalinks = []
    end

    self.using_pagarme(permalinks)
  end

  def budget_text_html
    catarse_email_auto_html_for budget, image_width: 600
  end

  def has_blank_service_fee?
    contributions.with_state(:confirmed).where("payment_service_fee IS NULL OR payment_service_fee = 0").present?
  end

  def can_show_account_link?
    ['online', 'waiting_funds', 'successful', 'approved'].include? state
  end

  def can_show_funding_period?
    ['online', 'waiting_funds', 'successful', 'failed'].include? state
  end

  def can_show_preview_link?
    ['draft', 'approved', 'rejected', 'in_analysis'].include? state
  end

  def using_pagarme?
    Project.enabled_to_use_pagarme.include?(self)
  end

  def subscribed_users
    User.subscribed_to_posts.subscribed_to_project(self.id)
  end

  def decorator
    @decorator ||= ProjectDecorator.new(self)
  end

  def expires_at
    @expires_at ||= Project.where(id: self.id).pluck('projects.expires_at').first
  end

  def pledged
    project_total.try(:pledged).to_f
  end

  def total_contributions
    project_total.try(:total_contributions).to_i
  end

  def total_payment_service_fee
    project_total.try(:total_payment_service_fee).to_f
  end

  def selected_rewards
    rewards.sort_asc.where(id: contributions.with_state('confirmed').map(&:reward_id))
  end

  def accept_contributions?
    online? && !expired?
  end

  def reached_goal?
    pledged >= goal
  end

  def expired?
    expires_at && expires_at < Time.zone.now
  end

  def in_time_to_wait?
    contributions.with_state('waiting_confirmation').present?
  end

  def pledged_and_waiting
    contributions.with_states(['confirmed', 'waiting_confirmation']).sum(:value)
  end

  def new_draft_recipient
    User.find_by_email CatarseSettings[:email_projects]
  end

  def should_fail?
    expired? && !reached_goal?
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

  def already_deployed?
    self.online? || self.successful? || self.failed? || self.waiting_funds?
  end

  private
  def self.between_dates(attribute, starts_at, ends_at)
    return all unless starts_at.present? && ends_at.present?
    where("(projects.#{attribute} AT TIME ZONE '#{Time.zone.tzinfo.name}')::date between to_date(?, 'dd/mm/yyyy') and to_date(?, 'dd/mm/yyyy')", starts_at, ends_at)
  end

  def self.get_routes
    routes = Rails.application.routes.routes.map do |r|
      r.path.spec.to_s.split('/').second.to_s.gsub(/\(.*?\)/, '')
    end
    routes.compact.uniq.reject(&:empty?)
  end

end
