class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :reward
  has_many :subscription_payments
end
