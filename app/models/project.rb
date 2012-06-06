# coding: utf-8
class Project < ActiveRecord::Base

  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper
  include ERB::Util
  include Rails.application.routes.url_helpers

  belongs_to :user
  belongs_to :category
  has_many :projects_curated_pages
  has_many :curated_pages, :through => :projects_curated_pages
  has_many :backers, :dependent => :destroy
  has_many :rewards, :dependent => :destroy
  has_many :updates, :dependent => :destroy
  has_many :notifications, :dependent => :destroy
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
    youtube width: 640, height: 430, wmode: "opaque"
    vimeo width: 640, height: 430
    redcloth :target => :_blank
    youtube :width => 580, :height => 378
    vimeo :width => 580, :height => 378
    link :target => :_blank
  end

  scope :visible, where(visible: true)
  scope :home_page, where(home_page: true)
  scope :not_home_page, where(home_page: false)
  scope :recommended, where(recommended: true)
  scope :not_recommended, where(recommended: false)
  scope :with_homepage_comment, where("home_page_comment IS NOT NULL AND home_page_comment <> ''")
  scope :pending, where("visible = false AND rejected = false")
  scope :expired, where("finished OR expires_at < current_timestamp")
  scope :not_expired, where("finished = false AND expires_at >= current_timestamp")
  scope :expiring, where("finished = false AND expires_at >= current_timestamp AND expires_at < (current_timestamp + interval '2 weeks')")
  scope :not_expiring, where("NOT (finished = false AND expires_at >= current_timestamp AND expires_at < (current_timestamp + interval '2 weeks'))")
  scope :recent, where("current_timestamp - projects.created_at <= '15 days'::interval")
  scope :last_week, where("projects.created_at > (current_timestamp - interval '1 week')")
  scope :successful, where(successful: true)
  scope :sort_by_explore_asc, order('(expires_at < current_timestamp) ASC, successful DESC, finished DESC, abs(EXTRACT(epoch FROM current_timestamp - expires_at)), created_at DESC')

  search_methods :visible, :home_page, :not_home_page, :recommended, :not_recommended, :expired, :not_expired, :expiring, :not_expiring, :recent, :successful

  validates_presence_of :name, :user, :category, :about, :headline, :goal, :expires_at, :video_url
  validates_length_of :headline, :maximum => 140
  validates_uniqueness_of :permalink, :allow_blank => true, :allow_nil => true
  before_create :store_image_url

  def store_image_url
    self.image_url = vimeo.thumbnail unless self.image_url
  end

  def to_param
    "#{self.id}-#{self.name.parameterize}"
  end

  def display_image
    return image_url if image_url
    return "user.png" unless vimeo.thumbnail
    vimeo.thumbnail
  end

  def display_expires_at
    I18n.l(expires_at.to_date)
  end

  def display_pledged
    number_to_currency pledged, :unit => 'R$', :precision => 0, :delimiter => '.'
  end

  def display_goal
    number_to_currency goal, :unit => 'R$', :precision => 0, :delimiter => '.'
  end

  def pledged
    backers.confirmed.sum(:value)
  end

  def total_backers
    backers.confirmed.count
  end

  def display_status
    if successful? and expired?
      'successful'
    elsif expired?
      'expired'
    elsif waiting_confirmation?
      'waiting_confirmation'
    elsif in_time?
      'in_time'
    end
  end

  def successful?
    return successful if finished
    pledged >= goal
  end

  def expired?
    return true if finished
    expires_at < Time.now
  end

  def waiting_confirmation?
    return false if finished or successful?
    expired? and Time.now < 3.weekdays_from(expires_at)
  end

  def in_time?
    return false if finished
    expires_at >= Time.now
  end

  def progress
    ((pledged / goal * 100).abs).round.to_i
  end

  def display_progress
    return 100 if successful?
    return 8 if progress > 0 and progress < 8
    progress
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

  def can_back?
    visible? and not expired? and not rejected?
  end

  def finish!
    return unless expired? and can_finish and not finished
    backers.confirmed.each do |backer|
      unless backer.can_refund or backer.notified_finish
        if successful?
          notification_text = I18n.t('project.finish.successful.notification_text', :link => link_to(truncate(name, :length => 38), "/projects/#{self.to_param}"), :locale => backer.user.locale)
          twitter_text = I18n.t('project.finish.successful.twitter_text', :name => name, :short_url => short_url, :locale => backer.user.locale)
          facebook_text = I18n.t('project.finish.successful.facebook_text', :name => name, :locale => backer.user.locale)
          email_subject = I18n.t('project.finish.successful.email_subject', :locale => backer.user.locale)
          email_text = I18n.t('project.finish.successful.email_text', :project_link => link_to(name, "#{I18n.t('site.base_url')}/projects/#{self.to_param}", :style => 'color: #008800;'), :user_link => link_to(user.display_name, "#{I18n.t('site.base_url')}/users/#{user.to_param}", :style => 'color: #008800;'), :locale => backer.user.locale)
          backer.user.notifications.create :project => self, :text => notification_text, :twitter_text => twitter_text, :facebook_text => facebook_text, :email_subject => email_subject, :email_text => email_text
          if backer.reward
            notification_text = I18n.t('project.finish.successful.reward_notification_text', :link => link_to(truncate(user.display_name, :length => 32), "/users/#{user.to_param}"), :locale => backer.user.locale)
            backer.user.notifications.create :project => self, :text => notification_text
          end
        else
          backer.generate_credits!
          notification_text = I18n.t('project.finish.unsuccessful.unsuccessful_text', :link => link_to(truncate(name, :length => 32), "/projects/#{self.to_param}"), :locale => backer.user.locale)
          backer.user.notifications.create :project => self, :text => notification_text
          notification_text = I18n.t('project.finish.unsuccessful.notification_text', :value => backer.display_value, :link => link_to(I18n.t('here', :locale => backer.user.locale), "#{I18n.t('site.base_url')}/credits"), :locale => backer.user.locale)
          email_subject = I18n.t('project.finish.unsuccessful.email_subject', :locale => backer.user.locale)
          email_text = I18n.t('project.finish.unsuccessful.email_text', :project_link => link_to(name, "#{I18n.t('site.base_url')}/projects/#{self.to_param}", :style => 'color: #008800;'), :value => backer.display_value, :credits_link => link_to(I18n.t('clicking_here', :locale => backer.user.locale), "#{I18n.t('site.base_url')}/credits", :style => 'color: #008800;'), :locale => backer.user.locale)
          backer.user.notifications.create :project => self, :text => notification_text, :email_subject => email_subject, :email_text => email_text
        end
        backer.update_attribute :notified_finish, true
      end
    end
    self.update_attributes finished: true, successful: successful?
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
      url: (self.permalink.blank? ? "/projects/#{self.to_param}" : '/' + self.permalink),
      full_uri: I18n.t('site.base_url') + (self.permalink.blank? ? Rails.application.routes.url_helpers.project_path(self) : '/' + self.permalink),
      expired: expired?,
      successful: successful?,
      waiting_confirmation: waiting_confirmation?,
      display_status_to_box: I18n.t("project.display_status.#{display_status}").capitalize,
      display_expires_at: display_expires_at,
      in_time: in_time?
    }
  end

end
