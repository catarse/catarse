class ChannelPost < ActiveRecord::Base
  include Shared::CatarseAutoHtml

  schema_associations
  has_many :notifications, dependent: :destroy

  validates_presence_of :user_id, :channel_id, :body, :body_html, :title
  #remove all whitespace from the start of the line so auto_html won't go crazy
  before_save -> {self.body = body.gsub(/^[^\S\n]+/, "")}

  catarse_auto_html_for field: :body, video_width: 560, video_height: 340

  scope :ordered, -> { order('id desc') }
  scope :visible, -> { where('visible') }

  def to_s
    self.title
  end

  def to_param
    "#{self.id}-#{self.title.parameterize}"
  end

  def post_number
    self.channel.posts.where('id <= ?', self.id).count(:all)
  end

  def email_body_html
    catarse_email_auto_html_for body, image_width: 513
  end

end
