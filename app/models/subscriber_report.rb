class SubscriberReport < ActiveRecord::Base
  belongs_to :channel
  acts_as_copy_target
end
