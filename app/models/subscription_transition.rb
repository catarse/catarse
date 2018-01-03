class SubscriptionTransition < ActiveRecord::Base
  self.table_name = 'common_schema.subscription_status_transitions'
  belongs_to :subscription, foreign_key: :subscription_id

end
