class AddNotificationToSystemNotifications < ActiveRecord::Migration[4.2]
  def up
    execute %Q{
CREATE TRIGGER system_notification_dispatcher AFTER INSERT ON notifications FOR EACH ROW EXECUTE PROCEDURE system_notification_dispatcher();
    }
  end

  def down
    execute %Q{
DROP TRIGGER system_notification_dispatcher ON notifications;
    }
  end
end
