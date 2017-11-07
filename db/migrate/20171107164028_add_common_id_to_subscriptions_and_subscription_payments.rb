class AddCommonIdToSubscriptionsAndSubscriptionPayments < ActiveRecord::Migration
  def change
    remove_column :subscriptions, :gateway_subscription_id
    add_column :subscriptions, :common_id, :uuid, null: false, foreign_key: false

    remove_column :subscription_payments, :gateway_payment_id
    add_column :subscription_payments, :common_id, :uuid, null: false, foreign_key: false
  end
end
