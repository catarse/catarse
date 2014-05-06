class ChannelPartner < ActiveRecord::Base
  schema_associations

  mount_uploader :image, ChannelPartnerUploader

  validates_presence_of :channel_id, :url, :image

  scope :ordered, -> { order('id desc') }
end
