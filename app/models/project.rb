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
    youtube width: 640, height: 430, wmode: "opaque"
    vimeo width: 640, height: 430
    redcloth :target => :_blank
    youtube :width => 580, :height => 378
    vimeo :width => 580, :height => 378
    link :target => :_blank
  end

  scope :visible, where(visible: true)
  scope :recommended, where(recommended: true)
  scope :expired, where("finished OR expires_at < current_timestamp")
  scope :not_expired, where("finished = false AND expires_at >= current_timestamp")
  scope :expiring, not_expired.where("expires_at < (current_timestamp + interval '2 weeks')")
  scope :not_expiring, not_expired.where("NOT (expires_at < (current_timestamp + interval '2 weeks'))")
  scope :recent, where("current_timestamp - projects.created_at <= '15 days'::interval")
  scope :successful, where(successful: true)
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

  validates_presence_of :name, :user, :category, :about, :headline, :goal, :expires_at, :video_url
  validates_length_of :headline, :maximum => 140
  validates_uniqueness_of :permalink, :allow_blank => true, :allow_nil => true
  validates_format_of :permalink, with: /^(\w|-)*$/, :allow_blank => true, :allow_nil => true
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
    project_total ? project_total.pledged : 0.0
  end

  def total_backers
    project_total ? project_total.total_backers : 0
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
    finished || expires_at < Time.now
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
          email_subject = I18n.t('project.finish.successful.email_subject', :project_name => name, :locale => backer.user.locale)

          email_text = I18n.t('project.finish.successful.email_text', {
            :project_link => link_to(name, "#{I18n.t('site.base_url')}/projects/#{self.to_param}", :style => 'color: #008800;'),
            :user_link => link_to(user.display_name, "#{I18n.t('site.base_url')}/users/#{user.to_param}", :style => 'color: #008800;'),
            :locale => backer.user.locale,
            :project_total_backers => total_backers,
            :project_pleged => display_pledged,
            :project_process => progress,
            :project_owner_name => user.display_name,
            :project_owner_email => mail_to(user.email, nil, :style => 'color: #008800;'),
            :facebook_button => facebook_button_to_notification_email(facebook_text),
            :twitter_button => twitter_button_to_notification_email(twitter_text)
          })

          backer.user.notifications.create :project => self, :text => notification_text, :twitter_text => twitter_text, :facebook_text => facebook_text, :email_subject => email_subject, :email_text => email_text
          if backer.reward
            notification_text = I18n.t('project.finish.successful.reward_notification_text', :link => link_to(truncate(user.display_name, :length => 32), "/users/#{user.to_param}"), :locale => backer.user.locale)
            backer.user.notifications.create :project => self, :text => notification_text
          end
        else
          notification_text = I18n.t('project.finish.unsuccessful.unsuccessful_text', :link => link_to(truncate(name, :length => 32), "/projects/#{self.to_param}"), :locale => backer.user.locale)
          backer.user.notifications.create :project => self, :text => notification_text
          notification_text = I18n.t('project.finish.unsuccessful.notification_text', :value => backer.display_value, :link => link_to(I18n.t('here', :locale => backer.user.locale), "#{I18n.t('site.base_url')}/users/#{backer.user.to_param}#credits"), :locale => backer.user.locale)
          email_subject = I18n.t('project.finish.unsuccessful.email_subject', 
                                 :locale => backer.user.locale,
                                 :project_name => name
                                )

          email_text = I18n.t('project.finish.unsuccessful.email_text', {
            :project_link => link_to(name, "#{I18n.t('site.base_url')}/projects/#{self.to_param}", :style => 'color: #008800;'),
            :value => backer.display_value,
            :credits_link => link_to(I18n.t('clicking_here', :locale => backer.user.locale), "#{I18n.t('site.base_url')}/users/#{backer.user.to_param}#credits", :style => 'color: #008800;'),
            :locale => backer.user.locale,
            :project_category => category.name,
            :explore_category_link => link_to(I18n.t('clicking_here', :locale => backer.user.locale), "#{I18n.t('site.base_url')}/explore##{category.name.parameterize}", :style => 'color: #008800;'),
            :user_provider => backer.user.display_provider,
            :link_to_term => link_to(I18n.t('click_term', :locale => backer.user.locale), "#{I18n.t('site.base_url')}/terms", :style => 'color: #008800;'),
            :project_owner_name => user.display_name,
            :project_owner_email => mail_to(user.email, nil, :style => 'color: #008800;')

          })

          backer.user.notifications.create :project => self, :text => notification_text, :email_subject => email_subject, :email_text => email_text
        end
        backer.update_attributes({ notified_finish: true })
      end
    end
    self.update_attributes finished: true, successful: successful?
  end

  def facebook_button_to_notification_email(text)
    img = "<img src='#{I18n.t('site.base_url')}/assets/auth/facebook_64.png' title='Facebook' class='social' />".html_safe
    link_to(img, "http://www.facebook.com/share.php?u=#{I18n.t('site.base_url')}/projects/#{self.to_param}&t=#{text}", :target => :_blank)
  end

  def twitter_button_to_notification_email(text)
    img = "<img src='#{I18n.t('site.base_url')}/assets/auth/twitter_64.png' title='Twitter' class='social' />".html_safe
    link_to(img, "http://twitter.com/?status=#{text}", :target => :_blank)
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
