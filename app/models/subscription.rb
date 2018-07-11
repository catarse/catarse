class Subscription < ActiveRecord::Base
  self.table_name = 'common_schema.subscriptions'
  belongs_to :user, primary_key: :common_id
  belongs_to :project, primary_key: :common_id
  belongs_to :reward, primary_key: :common_id
  has_many :subscription_payments
  has_many :subscription_transitions, foreign_key: :subscription_id

  scope :active_and_started, -> { where(status: %w(active started)) }

  def amount
    checkout_data['amount'].to_f / 100
  end
end
