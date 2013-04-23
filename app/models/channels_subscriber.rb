class ChannelsSubscriber < ActiveRecord::Base
  attr_accessible :user_id, :channel_id, :user, :channel
  schema_associations
  validates_presence_of :user_id, :channel_id
end
