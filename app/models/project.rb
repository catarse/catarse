# coding: utf-8
VIMEO_REGEX = /\Ahttp:\/\/(www\.)?vimeo.com\/(\d+)\z/
class Project < ActiveRecord::Base
  belongs_to :user
  belongs_to :category
  has_many :backers
  has_many :rewards
  accepts_nested_attributes_for :rewards
  validates_presence_of :name, :user, :category, :about, :headline, :goal, :deadline, :video_url
  validates_length_of :headline, :maximum => 140
  validates_format_of :video_url, :with => VIMEO_REGEX, :message => "somente URLs do Vimeo são aceitas"
  validate :verify_if_video_exists_on_vimeo
  def verify_if_video_exists_on_vimeo
    unless vimeo and vimeo["id"] == vimeo_id
      errors.add(:video_url, "deve existir no Vimeo")
    end
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
    return "user.png" unless vimeo
    vimeo["thumbnail_large"]
  end
  def display_about
    about.gsub("\n", "<br>")
  end
  def successful?
    pledged >= goal
  end
  def expired?
    deadline < Time.now
  end
  def in_time?
    deadline >= Time.now
  end
  def percent
    return 100 if successful?
    ((pledged / goal * 100).abs).round
  end
  def days_to_go
    ((deadline - Time.now).abs/60/60/24).round
  end
end
