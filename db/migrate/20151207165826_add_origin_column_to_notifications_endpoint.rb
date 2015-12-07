class AddOriginColumnToNotificationsEndpoint < ActiveRecord::Migration
  def up
    execute <<-SQL
    DROP VIEW "1".notifications;

    CREATE VIEW "1".notifications AS
    SELECT * FROM
    (
        SELECT c.name_pt AS origin, cn.user_id, cn.template_name, cn.created_at, cn.sent_at, cn.deliver_at
            FROM category_notifications cn JOIN categories c ON c.id = cn.category_id
        UNION ALL
        SELECT to_char(d.amount, 'L 999G990D00') AS origin, dn.user_id, dn.template_name, dn.created_at, dn.sent_at, dn.deliver_at
                FROM donation_notifications dn JOIN donations d ON d.id = dn.donation_id
        UNION ALL
        SELECT ''::text AS origin, user_id, template_name, created_at, sent_at, deliver_at FROM user_notifications
        UNION ALL
        SELECT p.name AS origin, pn.user_id, pn.template_name, pn.created_at, pn.sent_at, pn.deliver_at
            FROM project_notifications pn JOIN projects p ON p.id = pn.project_id
        UNION ALL
        SELECT to_char(ut.amount, 'L 999G990D00') AS origin, tn.user_id, tn.template_name, tn.created_at, tn.sent_at, tn.deliver_at
            FROM user_transfer_notifications tn JOIN user_transfers ut ON ut.id = tn.user_transfer_id
        UNION ALL
        SELECT p.name AS origin, ppn.user_id, ppn.template_name, ppn.created_at, ppn.sent_at, ppn.deliver_at
            FROM project_post_notifications ppn
            JOIN project_posts pp ON pp.id = ppn.project_post_id
            JOIN projects p ON p.id = pp.project_id
        UNION ALL
        SELECT p.name AS origin, cn.user_id, cn.template_name, cn.created_at, cn.sent_at, cn.deliver_at
            FROM contribution_notifications cn
            JOIN contributions co ON co.id = cn.contribution_id
            JOIN projects p ON p.id = co.project_id
    ) n;

    GRANT SELECT ON "1".notifications TO admin;
    SQL
  end

  def down
    execute <<-SQL
    DROP VIEW "1".notifications;

    CREATE VIEW "1".notifications AS
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

    GRANT SELECT ON "1".notifications TO admin;
    SQL
  end
end
