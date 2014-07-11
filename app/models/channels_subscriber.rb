class ChannelsSubscriber < ActiveRecord::Base
  attr_accessible :user_id, :channel_id, :user, :channel

  belongs_to :channel
  belongs_to :user

  validates_presence_of :user_id, :channel_id
end
