class SubscriptionPayment < ActiveRecord::Base
  self.table_name = 'common_schema.catalog_payments'
  belongs_to :user, primary_key: :common_id
  belongs_to :project, primary_key: :common_id
  belongs_to :reward, primary_key: :common_id
  belongs_to :subscription
  has_many :balance_transactions, foreign_key: :subscription_payment_uuid

  def already_in_balance?
    balance_transactions.where(event_name: %i[subscription_fee subscription_payment]).present?
  end
end
