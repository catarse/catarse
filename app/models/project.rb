# coding: utf-8
VIMEO_REGEX = /\Ahttp:\/\/(www\.)?vimeo.com\/(\d+)\z/
class Project < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper
  include ERB::Util
  include Rails.application.routes.url_helpers
  belongs_to :user
  belongs_to :category
  has_many :backers
  has_many :rewards
  accepts_nested_attributes_for :rewards
  scope :visible, where(:visible => true)
  scope :recommended, where(:recommended => true)
  scope :not_recommended, where(:recommended => false)
  scope :pending, where(:visible => false, :rejected => false)
  validates_presence_of :name, :user, :category, :about, :headline, :goal, :expires_at, :video_url
  validates_length_of :headline, :maximum => 140
  validates_format_of :video_url, :with => VIMEO_REGEX, :message => "somente URLs do Vimeo são aceitas"
  validate :verify_if_video_exists_on_vimeo
  before_create :store_image_url
  def store_image_url
    self.image_url = vimeo["thumbnail_large"] unless self.image_url
  end
  def verify_if_video_exists_on_vimeo
    unless vimeo and vimeo["id"] == vimeo_id
      errors.add(:video_url, "deve existir no Vimeo")
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
  def display_about
    h(about).gsub("\n", "<br>").html_safe
  end
  def display_expires_at
    expires_at.strftime('%d/%m')
  end
  def display_pledged
    number_to_currency pledged, :unit => 'R$ ', :precision => 0, :delimiter => '.'
  end
  def display_goal
    number_to_currency goal, :unit => 'R$ ', :precision => 0, :delimiter => '.'
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
      {:time => time, :unit => pluralize_without_number(time, 'dia')}
    elsif expires_at >= 1.hour.from_now
      time = ((expires_at - Time.now).abs/60/60).round
      {:time => time, :unit => pluralize_without_number(time, 'hora')}
    elsif expires_at >= 1.minute.from_now
      time = ((expires_at - Time.now).abs/60).round
      {:time => time, :unit => pluralize_without_number(time, 'minuto')}
    elsif expires_at >= 1.second.from_now
      time = ((expires_at - Time.now).abs).round
      {:time => time, :unit => pluralize_without_number(time, 'segundo')}
    else
      {:time => 0, :unit => 'segundos'}
    end
  end
  def can_back?
    visible and not expired? and not rejected
  end
end

