class AddNotificationTypeIdToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :notification_type_id, :integer
    add_foreign_key :notifications, :notification_types
  end
end
