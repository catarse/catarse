class SubscriptionTransition < ApplicationRecord
  self.table_name = 'common_schema.subscription_status_transitions'
  self.primary_key = :id

  belongs_to :subscription, foreign_key: :subscription_id
end
