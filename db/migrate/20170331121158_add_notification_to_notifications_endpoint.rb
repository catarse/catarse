class AddNotificationToNotificationsEndpoint < ActiveRecord::Migration
  def change
    execute %Q{
CREATE OR REPLACE VIEW "1"."notifications" AS 
 SELECT n.id,
    n.origin,
    n.user_id,
    n.template_name,
    n.created_at,
    n.sent_at,
    n.deliver_at,
    n.relation
   FROM ( SELECT ''::text AS origin,
            ns.user_id,
            ns.template_name::text,
            ns.created_at,
            ns.sent_at,
            ns.deliver_at,
            'notifications'::text AS relation,
            ns.id
           FROM notifications ns
            where ns.user_id is not null
        UNION ALL
        SELECT ''::text AS origin,
            u1.id as user_id,
            ns.template_name::text,
            ns.created_at,
            ns.sent_at,
            ns.deliver_at,
            'notifications'::text AS relation,
            ns.id
           FROM notifications ns
            join users u1 on u1.email = ns.user_email
        UNION ALL
        SELECT ''::text AS origin,
            dmn.user_id,
            dmn.template_name,
            dmn.created_at,
            dmn.sent_at,
            dmn.deliver_at,
            'direct_message_notifications'::text AS relation,
            dmn.id
           FROM direct_message_notifications dmn
        UNION ALL
         SELECT ''::text AS origin,
            ufn.user_id,
            ufn.template_name,
            ufn.created_at,
            ufn.sent_at,
            ufn.deliver_at,
            'user_follow_notifications'::text AS relation,
            ufn.id
           FROM user_follow_notifications ufn
        UNION ALL
         SELECT c.name_pt AS origin,
            cn.user_id,
            cn.template_name,
            cn.created_at,
            cn.sent_at,
            cn.deliver_at,
            'category_notifications'::text AS relation,
            cn.id
           FROM (category_notifications cn
             JOIN categories c ON ((c.id = cn.category_id)))
        UNION ALL
         SELECT to_char(d.amount, 'L 999G990D00'::text) AS origin,
            dn.user_id,
            dn.template_name,
            dn.created_at,
            dn.sent_at,
            dn.deliver_at,
            'donation_notifications'::text AS relation,
            dn.id
           FROM (donation_notifications dn
             JOIN donations d ON ((d.id = dn.donation_id)))
        UNION ALL
         SELECT ''::text AS origin,
            user_notifications.user_id,
            user_notifications.template_name,
            user_notifications.created_at,
            user_notifications.sent_at,
            user_notifications.deliver_at,
            'user_notifications'::text AS relation,
            user_notifications.id
           FROM user_notifications
        UNION ALL
         SELECT p.name AS origin,
            pn.user_id,
            pn.template_name,
            pn.created_at,
            pn.sent_at,
            pn.deliver_at,
            'project_notifications'::text AS relation,
            pn.id
           FROM (project_notifications pn
             JOIN projects p ON ((p.id = pn.project_id)))
        UNION ALL
         SELECT to_char(ut.amount, 'L 999G990D00'::text) AS origin,
            tn.user_id,
            tn.template_name,
            tn.created_at,
            tn.sent_at,
            tn.deliver_at,
            'user_transfer_notifications'::text AS relation,
            tn.id
           FROM (user_transfer_notifications tn
             JOIN user_transfers ut ON ((ut.id = tn.user_transfer_id)))
        UNION ALL
         SELECT p.name AS origin,
            ppn.user_id,
            ppn.template_name,
            ppn.created_at,
            ppn.sent_at,
            ppn.deliver_at,
            'project_post_notifications'::text AS relation,
            ppn.id
           FROM ((project_post_notifications ppn
             JOIN project_posts pp ON ((pp.id = ppn.project_post_id)))
             JOIN projects p ON ((p.id = pp.project_id)))
        UNION ALL
         SELECT p.name AS origin,
            cn.user_id,
            cn.template_name,
            cn.created_at,
            cn.sent_at,
            cn.deliver_at,
            'contribution_notifications'::text AS relation,
            cn.id
           FROM ((contribution_notifications cn
             JOIN contributions co ON ((co.id = cn.contribution_id)))
             JOIN projects p ON ((p.id = co.project_id)))) n;
}
  end
end
