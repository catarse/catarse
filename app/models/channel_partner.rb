class ChannelPartner < ActiveRecord::Base
  belongs_to :channel, inverse_of: :partners

  mount_uploader :image, ChannelPartnerUploader

  validates_presence_of :channel_id, :url, :image

  scope :ordered, -> { order('id desc') }

  before_save :convert_url

  def convert_url
    unless self.url.starts_with?('http://', 'https://')
      self.url = ['http://', self.url].join('')
    end
  end
end
