class AddPaymentIdToPaymentNotifications < ActiveRecord::Migration
  def change
    add_column :payment_notifications, :payment_id, :integer
  end
end
