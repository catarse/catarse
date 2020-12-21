class SubscriptionPaymentTransition < ApplicationRecord
  self.table_name = 'common_schema.payment_status_transitions'
  self.primary_key = :id

  belongs_to :subscription_payment, foreign_key: :catalog_payment_id
end
