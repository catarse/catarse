class SetNotificationDefaultsAndNotNull < ActiveRecord::Migration
  def up
    # origin_name
    execute "
    UPDATE notifications SET origin_name = (SELECT value FROM configurations c WHERE c.name = 'company_name');
    ALTER TABLE notifications ALTER origin_name SET NOT NULL;
    "
    # origin_email
    execute "
    UPDATE notifications SET origin_email = (SELECT value FROM configurations c WHERE c.name = 'email_contact');
    ALTER TABLE notifications ALTER origin_email SET NOT NULL;
    "
    # template_name
    execute "
    UPDATE notifications SET template_name = (SELECT name FROM notification_types nt WHERE nt.id = notifications.notification_type_id);
    ALTER TABLE notifications ALTER template_name SET NOT NULL;
    "
    # locale
    execute "
    UPDATE notifications SET locale = (SELECT locale FROM users u WHERE u.id = notifications.user_id);
    ALTER TABLE notifications ALTER locale SET NOT NULL;
    "
  end

  def down
  end
end
