class MigrateNotificationsToUserNotifications < ActiveRecord::Migration
  def change
    execute "
    INSERT INTO user_notifications
    (user_id, from_email, from_name, template_name, locale, sent_at, created_at, updated_at)
    SELECT
      user_id, origin_email, origin_name, template_name, locale, updated_at, created_at, updated_at
    FROM
      notifications
    WHERE
      template_name IN (
      'credits_warning',
      'user_deactivate',
      'new_user_registration'
      ) AND user_id IS NOT NULL;
    "
  end
end
