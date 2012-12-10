class AddNotNullToNotificationTypeIdInNotification < ActiveRecord::Migration
  def up
    execute "DELETE FROM notifications WHERE notification_type_id IS NULL"
    execute "ALTER TABLE notifications ALTER notification_type_id SET NOT NULL"
  end

  def down
    execute "ALTER TABLE notifications ALTER notification_type_id SET NULL"
  end
end
