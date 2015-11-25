class CreateNotificationsEndpoint < ActiveRecord::Migration
  def change
    execute <<-SQL
    CREATE OR REPLACE VIEW "1".notifications AS
    SELECT * FROM
    (
        SELECT user_id, template_name, created_at, sent_at, deliver_at FROM category_notifications
        UNION ALL
        SELECT user_id, template_name, created_at, sent_at, deliver_at FROM donation_notifications
        UNION ALL
        SELECT user_id, template_name, created_at, sent_at, deliver_at FROM user_notifications
        UNION ALL
        SELECT user_id, template_name, created_at, sent_at, deliver_at FROM project_notifications
        UNION ALL
        SELECT user_id, template_name, created_at, sent_at, deliver_at FROM user_transfer_notifications
        UNION ALL
        SELECT user_id, template_name, created_at, sent_at, deliver_at FROM project_post_notifications
        UNION ALL
        SELECT user_id, template_name, created_at, sent_at, deliver_at FROM contribution_notifications
    ) n;

    grant select on "1".notifications to admin;
    SQL
  end
end
