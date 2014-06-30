class Channel < ActiveRecord::Base
  extend CatarseAutoHtml

  include Shared::VideoHandler

  schema_associations

  validates_presence_of :name, :description, :permalink
  validates_uniqueness_of :permalink

  has_and_belongs_to_many :projects, -> { order_status.most_recent_first }
  has_many :subscribers, class_name: 'User', through: :channels_subscribers, source: :user
  has_many :subscriber_reports

  catarse_auto_html_for field: :how_it_works, video_width: 560, video_height: 340

  delegate :display_facebook, :display_twitter, :display_website, to: :decorator
  mount_uploader :image, ProfileUploader

  scope :by_permalink, ->(p) { where("lower(channels.permalink) = lower(?)", p) }

  def self.find_by_permalink!(string)
    self.by_permalink(string).first!
  end

  def curator
    users.first
  end

  def has_subscriber? user
    user && subscribers.where(id: user.id).first.present?
  end

  def to_s
    self.name
  end

  # Links to channels should be their permalink
  def to_param; self.permalink end

  # Using decorators
  def decorator
    @decorator ||= ChannelDecorator.new(self)
  end
end
