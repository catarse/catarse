class MigrateNotificationsToProjectPostNotifications < ActiveRecord::Migration
  def change
    execute "
    INSERT INTO project_post_notifications
    (user_id, project_post_id, from_email, from_name, template_name, locale, sent_at, created_at, updated_at)
    SELECT
      user_id, project_post_id, origin_email, origin_name, 'posts', locale, updated_at, created_at, updated_at
    FROM
      notifications
    WHERE
      template_name IN ('updates') AND project_post_id IS NOT NULL;
    "
  end
end
