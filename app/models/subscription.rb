class Subscription < ActiveRecord::Base
  self.table_name = 'common_schema.subscriptions'
  belongs_to :user, primary_key: :common_id
  belongs_to :project, primary_key: :common_id
  belongs_to :reward, primary_key: :common_id
  has_many :subscription_payments

end
