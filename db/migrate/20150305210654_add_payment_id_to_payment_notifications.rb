class AddPaymentIdToPaymentNotifications < ActiveRecord::Migration[4.2]
  def change
    add_column :payment_notifications, :payment_id, :integer
  end
end
