class RemoveStatusFromPaymentNotifications < ActiveRecord::Migration
  def up
    remove_column :payment_notifications, :status
  end

  def down
    add_column :payment_notifications, :status, :text
  end
end
