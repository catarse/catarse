require 'state_machine'
# coding: utf-8
class Project < ActiveRecord::Base

  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper
  include ERB::Util
  include Rails.application.routes.url_helpers
  include PgSearch
  extend CatarseAutoHtml

  before_save do
    if online_days_changed? || !self.expires_at.present?
      self.expires_at = DateTime.now+(online_days rescue 0).days
    end
  end

  mount_uploader :uploaded_image, LogoUploader

  delegate :display_status, :display_progress, :display_image, :display_expires_at,
    :display_pledged, :display_goal, :remaining_days,
    :to => :decorator

  schema_associations
  belongs_to :user
  has_many :backers, :dependent => :destroy
  has_many :rewards, :dependent => :destroy
  has_many :updates, :dependent => :destroy
  has_many :notifications, :dependent => :destroy
  has_one :project_total
  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :rewards

  has_vimeo_video :video_url, :message => I18n.t('project.vimeo_regex_validation')

  catarse_auto_html_for field: :about, video_width: 600, video_height: 403

  pg_search_scope :pg_search, against: [
      [:name, 'A'],
      [:headline, 'B'],
      [:about, 'C']
    ],
    associated_against:  {user: [:name, :address_city ]},
    :using => {tsearch: {:dictionary => "portuguese"}},
    ignoring: :accents

  def self.between_created_at(start_at, ends_at)
    return scoped unless start_at.present? && ends_at.present?
    where("created_at between to_date(?, 'dd/mm/yyyy') and to_date(?, 'dd/mm/yyyy')", start_at, ends_at)
  end

  scope :by_state, ->(state) { where(state: state) }
  scope :by_id, ->(id) { where(id: id) }
  scope :by_permalink, ->(p) { where(permalink: p) }
  scope :by_category_id, ->(id) { where(category_id: id) }
  scope :name_contains, ->(term) { where("unaccent(upper(name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :user_name_contains, ->(term) { joins(:user).where("unaccent(upper(users.name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :order_table, ->(sort) {
    if sort == 'desc'
      order('goal desc')
    else
      order('goal asc')
    end
  }

  scope :visible, where("state NOT IN ('draft', 'rejected')")
  scope :financial, where("(expires_at > current_timestamp - '15 days'::interval) AND (state in ('online', 'successful', 'waiting_funds'))")
  scope :recommended, where(recommended: true)
  scope :expired, where("expires_at < current_timestamp")
  scope :not_expired, where("expires_at >= current_timestamp")
  scope :expiring, not_expired.where("expires_at < (current_timestamp + interval '2 weeks')")
  scope :not_expiring, not_expired.where("NOT (expires_at < (current_timestamp + interval '2 weeks'))")
  scope :recent, where("current_timestamp - projects.created_at <= '15 days'::interval")
  scope :successful, where(state: 'successful')
  scope :online, where(state: 'online')
  scope :recommended_for_home, ->{
    includes(:user, :category, :project_total).
    recommended.
    visible.
    not_expired.
    order('random()').
    limit(4)
  }
  scope :order_for_search, ->{ reorder("
                                     CASE state
                                     WHEN 'online' THEN 1
                                     WHEN 'waiting_funds' THEN 2
                                     WHEN 'successful' THEN 3
                                     WHEN 'failed' THEN 4
                                     END ASC, created_at DESC, id DESC") }
  scope :expiring_for_home, ->(exclude_ids){
    includes(:user, :category, :project_total).where("coalesce(id NOT IN (?), true)", exclude_ids).visible.expiring.order('date(expires_at), random()').limit(3)
  }
  scope :recent_for_home, ->(exclude_ids){
    includes(:user, :category, :project_total).where("coalesce(id NOT IN (?), true)", exclude_ids).visible.recent.not_expiring.order('date(created_at) DESC, random()').limit(3)
  }
  scope :backed_by, ->(user_id){
    where("id IN (SELECT project_id FROM backers b WHERE b.confirmed AND b.user_id = ?)", user_id)
  }

  validates :video_url, presence: true, if: ->(p) { p.state_name == 'online' }
  validates_presence_of :name, :user, :category, :about, :headline, :goal, :permalink
  validates_length_of :headline, :maximum => 140
  validates_numericality_of :online_days, :less_than_or_equal_to => 60
  validates_uniqueness_of :permalink, :allow_blank => true, :allow_nil => true
  validates_format_of :permalink, with: /^(\w|-)*$/, :allow_blank => true, :allow_nil => true
  mount_uploader :video_thumbnail, LogoUploader

  def self.finish_projects!
    expired.each do |resource|
      Rails.logger.info "[FINISHING PROJECT #{resource.id}] #{resource.name}"
      resource.finish
    end
  end

  def self.state_names
    self.state_machine.states.map &:name
  end

  def subscribed_users
    User.subscribed_to_updates.subscribed_to_project(self.id)
  end

  def decorator
    @decorator ||= ProjectDecorator.new(self)
  end

  def to_param
    "#{self.id}-#{self.name.parameterize}"
  end

  def pledged
    project_total ? project_total.pledged : 0.0
  end

  def total_backers
    project_total ? project_total.total_backers : 0
  end

  def selected_rewards
    rewards.sort_asc.where(id: backers.confirmed.select('DISTINCT(reward_id)'))
  end

  def reached_goal?
    pledged >= goal
  end

  def finished?
    not online? and not draft? and not rejected?
  end

  # NOTE: I think that we just can look the expires_at column
  # the project enter on finished / failed state when expires ;)
  def expired?
    expires_at < Time.now
  end

  def waiting_confirmation?
    return false if finished or successful?
    expired? and Time.now < 4.weekdays_from(expires_at)
  end

  def in_time?
    !expired?
  end

  def progress
    return 0 if goal == 0.0 && pledged == 0.0
    return 100 if goal == 0.0 && pledged > 0.0
    ((pledged / goal * 100).abs).round.to_i
  end

  def time_to_go
    ['day', 'hour', 'minute', 'second'].each do |unit|
      if expires_at >= 1.send(unit).from_now
        time = ((expires_at - Time.now).abs/1.send(unit)).round
        return {time: time, unit: pluralize_without_number(time, I18n.t("datetime.prompts.#{unit}").downcase)}
      end
    end
    {time: 0, unit: pluralize_without_number(0, I18n.t('datetime.prompts.second').downcase)}
  end

  def remaining_text
    pluralize_without_number(time_to_go[:time], I18n.t('remaining_singular'), I18n.t('remaining_plural'))
  end

  def download_video_thumbnail
    self.video_thumbnail = open(self.vimeo.thumbnail) if self.video_url
  rescue OpenURI::HTTPError => e
    ::Airbrake.notify({ :error_class => "Vimeo thumbnail download", :error_message => "Vimeo thumbnail download: #{e.inspect}", :parameters => video_url}) rescue nil
  rescue TypeError => e
    ::Airbrake.notify({ :error_class => "Carrierwave does not like thumbnail file", :error_message => "Carrierwave does not like thumbnail file: #{e.inspect}", :parameters => video_url}) rescue nil
  end

  def as_json(options={})
    {
      id: id,
      name: name,
      user: user,
      category: category,
      image: display_image,
      headline: headline,
      progress: progress,
      display_progress: display_progress,
      pledged: display_pledged,
      created_at: created_at,
      time_to_go: time_to_go,
      remaining_text: remaining_text,
      embed_url: vimeo.embed_url,
      url: Rails.application.routes.url_helpers.project_by_slug_path(permalink, :locale => I18n.locale),
      full_uri: Rails.application.routes.url_helpers.project_by_slug_url(permalink, :locale => I18n.locale),
      expired: expired?,
      successful: successful? || reached_goal?,
      waiting_confirmation: waiting_confirmation?,
      waiting_funds: waiting_funds?,
      display_status_to_box: display_status.blank? ? nil : I18n.t("project.display_status.#{display_status}"),
      display_expires_at: display_expires_at,
      in_time: in_time?
    }
  end

  def in_time_to_wait?
    Time.now < 4.weekdays_from(expires_at)
  end
  
  def pending_backers_reached_the_goal?
    (pledged + backers.in_time_to_confirm.sum(&:value)) >= goal
  end

  #NOTE: state machine things
  state_machine :state, :initial => :draft do
    state :draft, value: 'draft'
    state :rejected, value: 'rejected'
    state :online, value: 'online'
    state :successful, value: 'successful'
    state :waiting_funds, value: 'waiting_funds'
    state :failed, value: 'failed'

    event :push_to_draft do
      transition all => :draft #NOTE: when use 'all' we can't use new hash style ;(
    end

    event :reject do
      transition draft: :rejected
    end

    event :approve do
      transition draft: :online
    end

    event :finish do
      transition online: :failed,             if: ->(project) {
        project.expired? && !project.pending_backers_reached_the_goal?
      }

      transition online: :waiting_funds,      if: ->(project) {
        project.expired? && project.in_time_to_wait? && project.pending_backers_reached_the_goal?
      }
      
      transition waiting_funds: :successful,  if: ->(project) {
        project.reached_goal? && !project.in_time_to_wait?
      }

      transition waiting_funds: :failed,      if: ->(project) {
        project.expired? && !project.reached_goal? && !project.in_time_to_wait?
      }
    end
    
    after_transition online: :failed, do: :after_transition_of_online_to_failed
    after_transition waiting_funds: [:successful, :failed], do: :after_transition_of_wainting_funds_to_successful_or_failed
    after_transition waiting_funds: :successful, do: :after_transition_of_wainting_funds_to_successful
    after_transition draft: :online, do: :after_transition_of_draft_to_online
    after_transition draft: :rejected, do: :after_transition_of_draft_to_rejected
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
    update_attributes({ online_date: DateTime.now, expires_at: (DateTime.now + online_days.days) })
    notify_observers :notify_owner_that_project_is_online
  end
end
