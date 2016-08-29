class AddNotificationToSystemNotifications < ActiveRecord::Migration
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
