class Subscription < ActiveRecord::Base
  self.table_name = 'common_schema.subscriptions'
  belongs_to :user
  belongs_to :project
  belongs_to :reward
  has_many :subscription_payments
end
