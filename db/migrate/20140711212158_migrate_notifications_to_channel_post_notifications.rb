class MigrateNotificationsToChannelPostNotifications < ActiveRecord::Migration
  def change
    execute "
    INSERT INTO channel_post_notifications
    (user_id, channel_post_id, from_email, from_name, template_name, locale, sent_at, created_at, updated_at)
    SELECT
      user_id, channel_post_id, origin_email, origin_name, template_name, locale, updated_at, created_at, updated_at
    FROM
      notifications
    WHERE
      template_name IN ('channel_post') AND channel_post_id IS NOT NULL;
    "
  end
end
