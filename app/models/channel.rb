class Channel < ActiveRecord::Base
  include Shared::CatarseAutoHtml
  include Shared::VideoHandler

  has_many :posts, class_name: "ChannelPost"
  has_many :partners, class_name: "ChannelPartner"

  validates_presence_of :name, :description, :permalink
  validates_uniqueness_of :permalink

  has_and_belongs_to_many :projects, -> { order_status.most_recent_first }
  has_many :subscribers, class_name: 'User', through: :channels_subscribers, source: :user
  has_many :channels_subscribers
  has_many :subscriber_reports
  has_many :users

  catarse_auto_html_for field: :how_it_works, video_width: 560, video_height: 340

  delegate :display_facebook, :display_twitter, :display_website, to: :decorator
  mount_uploader :image, ProfileUploader

  scope :by_permalink, ->(p) { where("lower(channels.permalink) = lower(?)", p) }

  def self.find_by_permalink!(string)
    self.by_permalink(string).first!
  end

  def has_subscriber? user
    user && subscribers.where(id: user.id).first.present?
  end

  def curator
    users.first
  end

  def to_s
    self.name
  end

  def host_path
    [self.permalink, CatarseSettings[:host]].join('.')
  end

  # Links to channels should be their permalink
  def to_param; self.permalink end

  # Using decorators
  def decorator
    @decorator ||= ChannelDecorator.new(self)
  end
end
