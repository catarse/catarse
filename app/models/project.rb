# coding: utf-8
VIMEO_REGEX = /\Ahttp:\/\/(www\.)?vimeo.com\/(\d+)\z/
class Project < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  belongs_to :user
  belongs_to :category
  has_many :backers
  has_many :rewards
  accepts_nested_attributes_for :rewards
  scope :visible, where(:visible => true)
  validates_presence_of :name, :user, :category, :about, :headline, :goal, :expires_at, :video_url
  validates_length_of :headline, :maximum => 140
  validates_format_of :video_url, :with => VIMEO_REGEX, :message => "somente URLs do Vimeo são aceitas"
  validate :verify_if_video_exists_on_vimeo
  before_create :store_urls
  def store_urls
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
    return unless video_url
    if result = video_url.match(VIMEO_REGEX)
      result[2]
    end
  end
  def video_embed_url
    "http://player.vimeo.com/video/#{vimeo_id}"
  end
  def display_image
    return "user.png" unless vimeo and vimeo["thumbnail_large"]
    vimeo["thumbnail_large"]
  end
  def display_about
    about.gsub("\n", "<br>")
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
  def in_time?
    expires_at >= Time.now
  end
  def percent
    ((pledged / goal * 100).abs).round
  end
  def display_percent
    return 100 if successful?
    return 8 if percent > 0 and percent < 8
    percent
  end
  def days_to_go
    return 0 if expires_at < Time.now
    ((expires_at - Time.now).abs/60/60/24).round
  end
end
