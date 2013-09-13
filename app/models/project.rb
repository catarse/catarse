# coding: utf-8
require 'state_machine'
class Project < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  include PgSearch
  extend CatarseAutoHtml

  mount_uploader :uploaded_image, ProjectUploader
  mount_uploader :video_thumbnail, ProjectUploader

  delegate :display_status, :display_progress, :display_image, :display_expires_at,
    :display_pledged, :display_goal, :remaining_days, :display_video_embed_url, :progress_bar, :successful_flag,
    to: :decorator

  schema_associations
  belongs_to :user
  has_many :backers, dependent: :destroy
  has_many :rewards, dependent: :destroy
  has_many :updates, dependent: :destroy
  has_many :notifications, dependent: :destroy

  has_and_belongs_to_many :channels

  has_one :project_total
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

  scope :by_progress, ->(progress) { joins(:project_total).where("project_totals.pledged >= projects.goal*?", progress.to_i/100.to_f) }
  scope :by_id, ->(id) { where(id: id) }
  scope :by_permalink, ->(p) { without_state('deleted').where("lower(permalink) = lower(?)", p) }
  scope :by_category_id, ->(id) { where(category_id: id) }
  scope :name_contains, ->(term) { where("unaccent(upper(name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :user_name_contains, ->(term) { joins(:user).where("unaccent(upper(users.name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :order_table, ->(sort) {
    if sort == 'desc'
      order('goal desc')
    elsif sort == 'asc'
      order('goal asc')
    else
      order('created_at desc')
    end
  }

  scope :near_of, ->(address_state) { where("EXISTS(SELECT true FROM users u WHERE u.id = projects.user_id AND lower(u.address_state) = lower(?))", address_state) }
  scope :to_finish, ->{ expired.with_states(['online', 'waiting_funds']) }
  scope :visible, -> { without_states(['draft', 'rejected', 'deleted']) }
  scope :financial, -> { with_states(['online', 'successful', 'waiting_funds']).where("projects.expires_at > (current_timestamp - '15 days'::interval)") }
  scope :recommended, -> { where(recommended: true) }
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
  scope :backed_by, ->(user_id){
    where("id IN (SELECT project_id FROM backers b WHERE b.state = 'confirmed' AND b.user_id = ?)", user_id)
  }

  scope :from_channels, ->{
    where("EXISTS (SELECT true FROM channels_projects cp WHERE cp.project_id = projects.id)")
  }

  attr_accessor :accepted_terms

  validates_acceptance_of :accepted_terms, on: :create

  validates :video_url, presence: true, if: ->(p) { p.state_name == 'online' }
  validates_presence_of :name, :user, :category, :about, :headline, :goal, :permalink
  validates_length_of :headline, maximum: 140
  validates_numericality_of :online_days, less_than_or_equal_to: 60
  validates_uniqueness_of :permalink, allow_blank: true, case_sensitive: false
  validates_format_of :permalink, with: /\A(\w|-)*\z/, allow_blank: true
  validates_format_of :video_url, with: /https?:\/\/(www\.)?vimeo.com\/(\d+)/, message: I18n.t('project.video_regex_validation'), allow_blank: true
  validate :permalink_cant_be_route, allow_nil: true

  def self.between_created_at(start_at, ends_at)
    return scoped unless start_at.present? && ends_at.present?
    where("created_at between to_date(?, 'dd/mm/yyyy') and to_date(?, 'dd/mm/yyyy')", start_at, ends_at)
  end

  def self.between_expires_at(start_at, ends_at)
    return scoped unless start_at.present? && ends_at.present?
    where("projects.expires_at between to_date(?, 'dd/mm/yyyy') and to_date(?, 'dd/mm/yyyy')", start_at, ends_at)
  end

  def self.finish_projects!
    to_finish.each do |resource|
      Rails.logger.info "[FINISHING PROJECT #{resource.id}] #{resource.name}"
      resource.finish
    end
  end

  def self.state_names
    self.state_machine.states.map do |state|
      state.name if state.name != :deleted
    end.compact!
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

  def video
    @video ||= VideoInfo.get(self.video_url) if self.video_url.present?
  end

  def pledged
    project_total ? project_total.pledged : 0.0
  end

  def total_backers
    project_total ? project_total.total_backers : 0
  end

  def total_payment_service_fee
    project_total ? project_total.total_payment_service_fee : 0.0
  end

  def selected_rewards
    rewards.sort_asc.where(id: backers.with_state('confirmed').map(&:reward_id))
  end

  def reached_goal?
    pledged >= goal
  end

  def finished?
    not online? and not draft? and not rejected?
  end

  def expired?
    expires_at && expires_at < Time.zone.now
  end

  def in_time_to_wait?
    backers.with_state('waiting_confirmation').count > 0
  end

  def in_time?
    !expired?
  end

  def progress
    return 0 if goal == 0.0
    ((pledged / goal * 100).abs).round(pledged.to_i.size).to_i
  end

  def time_to_go
    ['day', 'hour', 'minute', 'second'].each do |unit|
      if expires_at.to_i >= 1.send(unit).from_now.to_i
        time = ((expires_at - Time.zone.now).abs/1.send(unit)).round
        return {time: time, unit: pluralize_without_number(time, I18n.t("datetime.prompts.#{unit}").downcase)}
      end
    end
    {time: 0, unit: pluralize_without_number(0, I18n.t('datetime.prompts.second').downcase)}
  end

  def remaining_text
    pluralize_without_number(time_to_go[:time], I18n.t('remaining_singular'), I18n.t('remaining_plural'))
  end

  def update_video_embed_url
    self.video_embed_url = self.video.embed_url if self.video.present?
  end

  def download_video_thumbnail
    self.video_thumbnail = open(self.video.thumbnail_large) if self.video_url.present? && self.video
  rescue OpenURI::HTTPError => e
    Rails.logger.info "-----> #{e.inspect}"
  rescue TypeError => e
    Rails.logger.info "-----> #{e.inspect}"
  end

  def pending_backers_reached_the_goal?
    pledged_and_waiting >= goal
  end

  def can_go_to_second_chance?
    (pledged_and_waiting >= (goal*0.3.to_f)) && (4.weekdays_from(expires_at) >= DateTime.now)
  end

  def pledged_and_waiting
    backers.with_states(['confirmed', 'waiting_confirmation']).sum(:value)
  end

  def permalink_cant_be_route
    errors.add(:permalink, I18n.t("activerecord.errors.models.project.attributes.permalink.invalid")) if Project.permalink_on_routes?(permalink)
  end

  def self.permalink_on_routes?(permalink)
    permalink && self.get_routes.include?(permalink.downcase)
  end

  #NOTE: state machine things
  state_machine :state, initial: :draft do
    state :draft, value: 'draft'
    state :rejected, value: 'rejected'
    state :online, value: 'online'
    state :successful, value: 'successful'
    state :waiting_funds, value: 'waiting_funds'
    state :failed, value: 'failed'
    state :deleted, value: 'deleted'

    event :push_to_draft do
      transition all => :draft #NOTE: when use 'all' we can't use new hash style ;(
    end

    event :push_to_trash do
      transition [:draft, :rejected] => :deleted
    end

    event :reject do
      transition draft: :rejected
    end

    event :approve do
      transition draft: :online
    end

    event :finish do
      transition online: :failed,             if: ->(project) {
        project.expired? && !project.pending_backers_reached_the_goal? && !project.can_go_to_second_chance?
      }

      transition online: :waiting_funds,      if: ->(project) {
        project.expired? && (project.pending_backers_reached_the_goal? || project.can_go_to_second_chance?)
      }

      transition waiting_funds: :successful,  if: ->(project) {
        project.reached_goal? && !project.in_time_to_wait?
      }

      transition waiting_funds: :failed,      if: ->(project) {
        project.expired? && !project.reached_goal? && !project.in_time_to_wait? && !project.can_go_to_second_chance?
      }

      transition waiting_funds: :waiting_funds,      if: ->(project) {
        project.expired? && !project.reached_goal? && (project.in_time_to_wait? || project.can_go_to_second_chance?)
      }
    end

    after_transition online: :waiting_funds, do: :after_transition_of_online_to_waiting_funds
    after_transition online: :failed, do: :after_transition_of_online_to_failed
    after_transition waiting_funds: [:successful, :failed], do: :after_transition_of_wainting_funds_to_successful_or_failed
    after_transition waiting_funds: :successful, do: :after_transition_of_wainting_funds_to_successful
    after_transition draft: :online, do: :after_transition_of_draft_to_online
    after_transition draft: :rejected, do: :after_transition_of_draft_to_rejected
    after_transition any => [:failed, :successful], :do => :after_transition_of_any_to_failed_or_successful
    after_transition :waiting_funds => [:failed, :successful], :do => :after_transition_of_waiting_funds_to_failed_or_successful
    after_transition [:draft, :rejected] => :deleted, :do => :after_transition_of_draft_or_rejected_to_deleted
  end

  def after_transition_of_draft_or_rejected_to_deleted
    update_attributes({ permalink: "deleted_project_#{id}"})
  end

  def after_transition_of_online_to_waiting_funds
    notify_observers :notify_owner_that_project_is_waiting_funds
  end

  def after_transition_of_waiting_funds_to_failed_or_successful
    notify_observers :notify_admin_that_project_reached_deadline
  end

  def after_transition_of_any_to_failed_or_successful
    notify_observers :sync_with_mailchimp
  end

  def after_transition_of_online_to_failed
    notify_observers :notify_users
  end

  def after_transition_of_wainting_funds_to_successful
    notify_observers :notify_owner_that_project_is_successful
  end

  def after_transition_of_draft_to_rejected
    notify_observers :notify_owner_that_project_is_rejected
  end

  def after_transition_of_wainting_funds_to_successful_or_failed
    notify_observers :notify_users
  end

  def after_transition_of_draft_to_online
    update_attributes({ online_date: DateTime.now })
    notify_observers :notify_owner_that_project_is_online
  end

  def new_draft_recipient
    email = (channels.first.email rescue nil) || ::Configuration[:email_projects]
    User.where(email: email).first
  end

  def new_draft_project_notification_type
    channels.first ? :new_draft_project_channel : :new_draft_project
  end

  def new_project_received_notification_type
    channels.first ? :project_received_channel : :project_received
  end

  private
  def self.get_routes
    routes = Rails.application.routes.routes.map do |r|
      r.path.spec.to_s.split('/').second.to_s.gsub(/\(.*?\)/, '')
    end
    routes.compact.uniq
  end
end
