# coding: utf-8
VIMEO_REGEX = /\Ahttp:\/\/(www\.)?vimeo.com\/(\d+)\z/
class Project < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper
  include ERB::Util
  include Rails.application.routes.url_helpers
  acts_as_commentable
  belongs_to :user
  belongs_to :category
  belongs_to :site
  has_many :backers
  has_many :rewards
  has_many :comments, :as => :commentable, :conditions => {:project_update => false}
  has_many :updates, :as => :commentable, :class_name => "Comment", :conditions => {:project_update => true}
  has_many :projects_sites
  has_many :sites_present, :through => :projects_sites, :source => :site
  accepts_nested_attributes_for :rewards
  auto_html_for :about do
    html_escape :map => { 
      '&' => '&amp;',  
      '>' => '&gt;',
      '<' => '&lt;',
      '"' => '"' }
    redcloth :target => :_blank
    link :target => :_blank
  end
  scope :visible, where("projects_sites.visible = true")
  scope :home_page, where("projects_sites.home_page = true")
  scope :not_home_page, where("projects_sites.home_page = false")
  scope :recommended, where("projects_sites.recommended = true")
  scope :not_recommended, where("projects_sites.recommended = false")
  scope :pending, where("projects_sites.visible = false AND projects_sites.rejected = false")
  scope :expiring, where("expires_at >= current_timestamp AND expires_at < (current_timestamp + interval '2 weeks')")
  scope :recent, where("projects.created_at > (current_timestamp - interval '1 month')")
  scope :successful, where("goal <= (SELECT sum(value) FROM backers WHERE project_id = projects.id AND confirmed) AND expires_at < current_timestamp")
  scope :not_successful, where("NOT (goal <= (SELECT sum(value) FROM backers WHERE project_id = projects.id AND confirmed) AND expires_at < current_timestamp)")
  scope :unsuccessful, where("goal > (SELECT sum(value) FROM backers WHERE project_id = projects.id AND confirmed) AND expires_at < current_timestamp")
  scope :not_unsuccessful, where("NOT (goal > (SELECT sum(value) FROM backers WHERE project_id = projects.id AND confirmed) AND expires_at < current_timestamp)")
  validates_presence_of :name, :user, :category, :about, :headline, :goal, :expires_at, :video_url, :site
  validates_length_of :headline, :maximum => 140
  validates_format_of :video_url, :with => VIMEO_REGEX, :message => I18n.t('project.vimeo_regex_validation')
  validate :verify_if_video_exists_on_vimeo
  before_create :store_image_url
  def store_image_url
    self.image_url = vimeo["thumbnail_large"] unless self.image_url
  end
  def verify_if_video_exists_on_vimeo
    unless vimeo and vimeo["id"] == vimeo_id
      errors.add(:video_url, I18n.t('project.verify_if_video_exists_on_vimeo'))
    end
  end
  def to_param
    "#{self.id}-#{self.name.parameterize}"
  end
  def vimeo
    return @vimeo if @vimeo
    return unless vimeo_id
    @vimeo = Vimeo::Simple::Video.info(vimeo_id)
    if @vimeo.parsed_response and @vimeo.parsed_response[0]
      @vimeo = @vimeo.parsed_response[0]
    else
      @vimeo = nil
    end
  rescue
    @vimeo = nil
  end
  def vimeo_id
    return @vimeo_id if @vimeo_id
    return unless video_url
    if result = video_url.match(VIMEO_REGEX)
      @vimeo_id = result[2]
    end
  end
  def video_embed_url
    "http://player.vimeo.com/video/#{vimeo_id}"
  end
  def display_image
    return image_url if image_url
    return "user.png" unless vimeo and vimeo["thumbnail_large"]
    vimeo["thumbnail_large"]
  end
  def display_expires_at
    expires_at.strftime('%d/%m')
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
  def successful?
    pledged >= goal
  end
  def expired?
    expires_at < Time.now
  end
  def waiting_confirmation?
    return false if successful?
    expired? and Time.now < 3.weekdays_from(expires_at)
  end
  def in_time?
    expires_at >= Time.now
  end
  def percent
    ((pledged / goal * 100).abs).round.to_i
  end
  def display_percent
    return 100 if successful?
    return 8 if percent > 0 and percent < 8
    percent
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
  def present?(site)
    projects_sites.where("site_id = #{site.id}").count > 0
  end
  def visible?(site)
    projects_sites.where("visible AND site_id = #{site.id}").count > 0
  end
  def rejected?(site)
    projects_sites.where("rejected AND site_id = #{site.id}").count > 0
  end
  def can_back?(site)
    visible?(site) and not expired? and not rejected?(site)
  end
  def finish!
    return unless expired? and can_finish and not finished
    backers.confirmed.each do |backer|
      unless backer.can_refund or backer.notified_finish
        if successful?
          notification_text = I18n.t('project.finish.successful.notification_text', :link => link_to(truncate(name, :length => 38), "/projects/#{self.to_param}"), :locale => backer.user.locale)
          twitter_text = I18n.t('project.finish.successful.twitter_text', :name => name, :in_the_twitter => site.in_the_twitter, :short_url => short_url, :locale => backer.user.locale)
          facebook_text = I18n.t('project.finish.successful.facebook_text', :name => name, :in_the_name => site.in_the_name, :locale => backer.user.locale)
          email_subject = I18n.t('project.finish.successful.email_subject', :in_the_name => site.in_the_name, :locale => backer.user.locale)
          email_text = I18n.t('project.finish.successful.email_text', :project_link => link_to(name, "http://#{site.host}/projects/#{self.to_param}", :style => 'color: #008800;'), :in_the_name => site.in_the_name, :user_link => link_to(user.display_name, "http://#{site.host}/users/#{user.to_param}", :style => 'color: #008800;'), :locale => backer.user.locale)
          backer.user.notifications.create :site => site, :project => self, :text => notification_text, :twitter_text => twitter_text, :facebook_text => facebook_text, :email_subject => email_subject, :email_text => email_text
          if backer.reward
            notification_text = I18n.t('project.finish.successful.reward_notification_text', :link => link_to(truncate(user.display_name, :length => 32), "/users/#{user.to_param}"), :locale => backer.user.locale)
            backer.user.notifications.create :site => site, :project => self, :text => notification_text
          end
        else
          backer.generate_credits!
          notification_text = I18n.t('project.finish.unsuccessful.unsuccessful_text', :link => link_to(truncate(name, :length => 32), "/projects/#{self.to_param}"), :locale => backer.user.locale)
          backer.user.notifications.create :site => site, :project => self, :text => notification_text
          notification_text = I18n.t('project.finish.unsuccessful.notification_text', :value => backer.display_value, :link => link_to(I18n.t('here', :locale => backer.user.locale), "http://#{site.host}/credits"), :locale => backer.user.locale)
          email_subject = I18n.t('project.finish.unsuccessful.email_subject', :in_the_name => site.in_the_name, :locale => backer.user.locale)
          email_text = I18n.t('project.finish.unsuccessful.email_text', :project_link => link_to(name, "http://#{site.host}/projects/#{self.to_param}", :style => 'color: #008800;'), :value => backer.display_value, :credits_link => link_to(I18n.t('clicking_here', :locale => backer.user.locale), "http://#{site.host}/credits", :style => 'color: #008800;'), :locale => backer.user.locale)
          backer.user.notifications.create :site => site, :project => self, :text => notification_text, :email_subject => email_subject, :email_text => email_text
        end
        backer.update_attribute :notified_finish, true
      end
    end
    self.update_attribute :finished, true
  end
  def as_json(options={})
    {
      :id => id,
      :name => name,
      :user => user
    }
  end
end
