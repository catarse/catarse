# coding: utf-8
class Project < ActiveRecord::Base
  schema_associations

  extend CatarseAutoHtml

  include PgSearch

  include Shared::StateMachineHelpers
  include Project::StateMachineHandler
  include Project::VideoHandler
  include Project::CustomValidators

  mount_uploader :uploaded_image, ProjectUploader

  delegate :display_status, :progress, :display_progress, :display_image, :display_expires_at, :remaining_text, :time_to_go,
    :display_pledged, :display_goal, :remaining_days, :progress_bar, :status_flag,
    to: :decorator

  has_and_belongs_to_many :channels
  has_one :project_total
  has_many :rewards
  accepts_nested_attributes_for :rewards

  catarse_auto_html_for field: :about, video_width: 600, video_height: 403

  pg_search_scope :pg_search, against: [
      [:name, 'A'],
      [:headline, 'B'],
      [:about, 'C']
    ],
    associated_against:  {user: [:name, :address_city ]},
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
  scope :name_contains, ->(term) { where("unaccent(upper(name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :user_name_contains, ->(term) { joins(:user).where("unaccent(upper(users.name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :near_of, ->(address_state) { where("EXISTS(SELECT true FROM users u WHERE u.id = projects.user_id AND lower(u.address_state) = lower(?))", address_state) }
  scope :to_finish, ->{ expired.with_states(['online', 'waiting_funds']) }
  scope :visible, -> { without_states(['draft', 'rejected', 'deleted', 'in_analysis']) }
  scope :financial, -> { with_states(['online', 'successful', 'waiting_funds']).where("projects.expires_at > (current_timestamp - '15 days'::interval)") }
  scope :expired, -> { where("projects.expires_at < current_timestamp") }
  scope :not_expired, -> { where("projects.expires_at >= current_timestamp") }
  scope :expiring, -> { not_expired.where("projects.expires_at <= (current_timestamp + interval '2 weeks')") }
  scope :not_expiring, -> { not_expired.where("NOT (projects.expires_at <= (current_timestamp + interval '2 weeks'))") }
  scope :recent, -> { where("(current_timestamp - projects.online_date) <= '5 days'::interval") }
  scope :order_for_search, ->{ reorder("
                                     CASE projects.state
                                     WHEN 'online' THEN 1
                                     WHEN 'waiting_funds' THEN 2
                                     WHEN 'successful' THEN 3
                                     WHEN 'failed' THEN 4
                                     END ASC, projects.online_date DESC, projects.created_at DESC") }
  scope :order_for_admin, -> {
    reorder("
            CASE projects.state
            WHEN 'in_analysis' THEN 1
            WHEN 'waiting_funds' THEN 2
            WHEN 'successful' THEN 3
            WHEN 'failed' THEN 4
            END ASC, projects.online_date DESC, projects.created_at DESC")
  }

  scope :contributed_by, ->(user_id){
    where("id IN (SELECT project_id FROM contributions b WHERE b.state = 'confirmed' AND b.user_id = ?)", user_id)
  }


  scope :from_channels, ->(channels){
    where("EXISTS (SELECT true FROM channels_projects cp WHERE cp.project_id = projects.id AND cp.channel_id = ?)", channels)
  }

  scope :with_contributions_confirmed_today, -> {
    joins(:contributions).merge(Contribution.confirmed_today).uniq
  }

  attr_accessor :accepted_terms

  validates_acceptance_of :accepted_terms, on: :create

  validates :video_url, presence: true, if: ->(p) { p.state_name == 'online' }
  validates_presence_of :name, :user, :category, :about, :headline, :goal, :permalink
  validates_length_of :headline, maximum: 140
  validates_numericality_of :online_days, less_than_or_equal_to: 60
  validates_uniqueness_of :permalink, allow_blank: true, case_sensitive: false
  validates_format_of :permalink, with: /\A(\w|-)*\z/, allow_blank: true

  [:between_created_at, :between_expires_at, :between_online_date, :between_updated_at].each do |name|
    define_singleton_method name do |starts_at, ends_at|
      between_dates name.to_s.gsub('between_',''), starts_at, ends_at
    end
  end

  def self.goal_between(starts_at, ends_at)
    where("goal BETWEEN ? AND ?", starts_at, ends_at)
  end

  def self.order_by(sort_field)
    return scoped unless sort_field =~ /^\w+(\.\w+)?\s(desc|asc)$/i
    order(sort_field)
  end

  def subscribed_users
    User.subscribed_to_updates.subscribed_to_project(self.id)
  end

  def decorator
    @decorator ||= ProjectDecorator.new(self)
  end

  def expires_at
    online_date && (online_date + online_days.days).end_of_day
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

  def reached_goal?
    pledged >= goal
  end

  def expired?
    expires_at && expires_at < Time.zone.now
  end

  def in_time_to_wait?
    contributions.with_state('waiting_confirmation').count > 0
  end

  def pending_contributions_reached_the_goal?
    pledged_and_waiting >= goal
  end

  def pledged_and_waiting
    contributions.with_states(['confirmed', 'waiting_confirmation']).sum(:value)
  end

  def new_draft_recipient
    email = last_channel.try(:email) || ::Configuration[:email_projects]
    User.where(email: email).first
  end

  def last_channel
    @last_channel ||= channels.last
  end

  def notification_type type
    channels.first ? "#{type}_channel".to_sym : type
  end

  def should_fail?
    expired? && !reached_goal?
  end

  def state_warning_template
    "#{state}_warning"
  end

  private
  def self.between_dates(attribute, starts_at, ends_at)
    return scoped unless starts_at.present? && ends_at.present?
    where("projects.#{attribute}::date between to_date(?, 'dd/mm/yyyy') and to_date(?, 'dd/mm/yyyy')", starts_at, ends_at)
  end

  def self.get_routes
    routes = Rails.application.routes.routes.map do |r|
      r.path.spec.to_s.split('/').second.to_s.gsub(/\(.*?\)/, '')
    end
    routes.compact.uniq
  end
end
