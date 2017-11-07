class SubscriptionPayment < ActiveRecord::Base
  belongs_to :subscription
  has_many :balance_transactions

end
