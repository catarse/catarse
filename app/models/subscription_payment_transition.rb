class SubscriptionPaymentTransition < ActiveRecord::Base
  self.table_name = 'common_schema.payment_status_transitions'
  belongs_to :subscription_payment, foreign_key: :catalog_payment_id

end
