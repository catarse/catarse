require 'state_machine'
# coding: utf-8
class Project < ActiveRecord::Base

  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper
  include ERB::Util
  include Rails.application.routes.url_helpers

  before_save do
    unless expires_at.present?
      expires_at = DateTime.now+(online_days.days rescue 0) 
    end
  end

  delegate :display_status, :display_progress, :display_image, :display_expires_at,
    :display_pledged, :display_goal,
    :to => :decorator

  belongs_to :user
  belongs_to :category
  has_many :projects_curated_pages
  has_many :curated_pages, :through => :projects_curated_pages
  has_many :backers, :dependent => :destroy
  has_many :rewards, :dependent => :destroy
  has_many :updates, :dependent => :destroy
  has_many :notifications, :dependent => :destroy
  has_one :project_total
  has_and_belongs_to_many :managers, :join_table => "projects_managers", :class_name => 'User'
  accepts_nested_attributes_for :rewards

  has_vimeo_video :video_url, :message => I18n.t('project.vimeo_regex_validation')

  auto_html_for :about do
    html_escape :map => {
      '&' => '&amp;',
      '>' => '&gt;',
      '<' => '&lt;',
      '"' => '"' }
    image
    youtube width: 600, height: 430, wmode: "opaque"
    vimeo width: 600, height: 403
    redcloth :target => :_blank
    link :target => :_blank
  end

  scope :visible, where("state NOT IN ('draft', 'rejected')")
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
  scope :expiring_for_home, ->(exclude_ids){
    includes(:user, :category, :project_total).where("coalesce(id NOT IN (?), true)", exclude_ids).visible.expiring.order('date(expires_at), random()').limit(3)
  }
  scope :recent_for_home, ->(exclude_ids){
    includes(:user, :category, :project_total).where("coalesce(id NOT IN (?), true)", exclude_ids).visible.recent.not_expiring.order('date(created_at) DESC, random()').limit(3)
  }

  search_methods :visible, :recommended, :expired, :not_expired, :expiring, :not_expiring, :recent, :successful

  validates_presence_of :name, :user, :category, :about, :headline, :goal, :video_url
  validates_length_of :headline, :maximum => 140
  validates_uniqueness_of :permalink, :allow_blank => true, :allow_nil => true
  validates_format_of :permalink, with: /^(\w|-)*$/, :allow_blank => true, :allow_nil => true
  mount_uploader :video_thumbnail, LogoUploader

  def self.finish_projects!
    expired.each do |resource| 
      Rails.logger.info "[FINISHING PROJECT #{resource.id}] #{resource.name}"
      resource.finish 
    end
  end

  def self.unaccent_search search
    joins(:user).where("unaccent(projects.name || headline || about || coalesce(users.name,'') || coalesce(users.address_city,'')) ~* unaccent(?)", search)
  end

  def users_who_backed
    User.who_backed_project(self.id)
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
    expired? and Time.now < 3.weekdays_from(expires_at)
  end

  def in_time?
    !expired?
  end

  def progress
    ((pledged / goal * 100).abs).round.to_i
  end

  def time_to_go
    if expires_at >= 1.day.from_now
      time = ((expires_at - Time.now).abs/60/60/24).round
      {:time => time, :unit => pluralize_without_number(time, I18n.t('datetime.prompts.day').downcase)}
    elsif expires_at >= 1.hour.from_now
      time = ((expires_at - Time.now).abs/60/60).round
      {:time => time, :unit => pluralize_without_number(time, I18n.t('datetime.prompts.hour').downcase)}
    elsif expires_at >= 1.minute.from_now
      time = ((expires_at - Time.now).abs/60).round
      {:time => time, :unit => pluralize_without_number(time, I18n.t('datetime.prompts.minute').downcase)}
    elsif expires_at >= 1.second.from_now
      time = ((expires_at - Time.now).abs).round
      {:time => time, :unit => pluralize_without_number(time, I18n.t('datetime.prompts.second').downcase)}
    else
      {:time => 0, :unit => pluralize_without_number(0, I18n.t('datetime.prompts.second').downcase)}
    end
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

  def can_back?
    online?
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
      url: (self.permalink.blank? ? "/projects/#{self.to_param}" : '/' + self.permalink),
      full_uri: I18n.t('site.base_url') + (self.permalink.blank? ? Rails.application.routes.url_helpers.project_path(self) : '/' + self.permalink),
      expired: expired?,
      successful: successful? || reached_goal?,
      waiting_confirmation: waiting_confirmation?,
      display_status_to_box: I18n.t("project.display_status.#{display_status}").capitalize,
      display_expires_at: display_expires_at,
      in_time: in_time?
    }
  end

  def in_time_to_wait?
    Time.now < 3.weekdays_from(expires_at)
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
      transition online: :waiting_funds,      if: ->(project) {
        project.expired? and project.in_time_to_wait?
      }

      transition waiting_funds: :successful,  if: ->(project) {
        project.expired? and project.reached_goal? and not project.in_time_to_wait?
      }

      transition waiting_funds: :failed,      if: ->(project) {
        project.expired? and not project.reached_goal? and not project.in_time_to_wait?
      }
    end

    after_transition waiting_funds: [:successful, :failed], do: :after_transition_of_wainting_funds_to_successful_or_failed
    after_transition draft: :online, do: :after_transition_of_draft_to_online
  end

  def after_transition_of_wainting_funds_to_successful_or_failed
    notify_observers :notify_users
  end

  def after_transition_of_draft_to_online
    notify_observers :notify_owner_that_project_is_online
  end
end
