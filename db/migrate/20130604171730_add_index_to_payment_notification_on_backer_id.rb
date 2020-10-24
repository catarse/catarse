class AddIndexToPaymentNotificationOnBackerId < ActiveRecord::Migration[4.2]
  def change
    add_index :payment_notifications, :backer_id
  end
end
