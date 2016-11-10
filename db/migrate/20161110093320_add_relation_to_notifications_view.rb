class AddRelationToNotificationsView < ActiveRecord::Migration
  def up
    execute %Q{
DROP VIEW "1".notifications;
CREATE OR REPLACE VIEW "1"."notifications" AS 
 SELECT 
    n.id,
    n.origin,
    n.user_id,
    n.template_name,
    n.created_at,
    n.sent_at,
    n.deliver_at,
    n.relation
   FROM ( 
        SELECT ''::text AS origin,
            dmn.user_id,
            dmn.template_name,
            dmn.created_at,
            dmn.sent_at,
            dmn.deliver_at,
            'direct_message_notifications' as relation,
            dmn.id
           FROM direct_message_notifications dmn
        UNION ALL
        SELECT ''::text AS origin,
            ufn.user_id,
            ufn.template_name,
            ufn.created_at,
            ufn.sent_at,
            ufn.deliver_at,
            'user_follow_notifications' as relation,
            ufn.id
           FROM user_follow_notifications ufn
        UNION ALL   
        SELECT c.name_pt AS origin,
            cn.user_id,
            cn.template_name,
            cn.created_at,
            cn.sent_at,
            cn.deliver_at,
            'category_notifications' as relation,
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
            'donation_notifications' as relation,
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
            'user_notifications' as relation,
            user_notifications.id
           FROM user_notifications
        UNION ALL
         SELECT p.name AS origin,
            pn.user_id,
            pn.template_name,
            pn.created_at,
            pn.sent_at,
            pn.deliver_at,
            'project_notifications' as relation,
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
            'user_transfer_notifications' as relation,
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
            'project_post_notifications' as relation,
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
            'contribution_notifications' as relation,
            cn.id
           FROM ((contribution_notifications cn
             JOIN contributions co ON ((co.id = cn.contribution_id)))
             JOIN projects p ON ((p.id = co.project_id)))) n;
    grant select on "1".notifications to admin;
    }
  end

  def down
    execute %Q{
DROP VIEW "1".notifications;
CREATE OR REPLACE VIEW "1"."notifications" AS 
 SELECT n.origin,
    n.user_id,
    n.template_name,
    n.created_at,
    n.sent_at,
    n.deliver_at
   FROM ( SELECT c.name_pt AS origin,
            cn.user_id,
            cn.template_name,
            cn.created_at,
            cn.sent_at,
            cn.deliver_at
           FROM (category_notifications cn
             JOIN categories c ON ((c.id = cn.category_id)))
        UNION ALL
         SELECT to_char(d.amount, 'L 999G990D00'::text) AS origin,
            dn.user_id,
            dn.template_name,
            dn.created_at,
            dn.sent_at,
            dn.deliver_at
           FROM (donation_notifications dn
             JOIN donations d ON ((d.id = dn.donation_id)))
        UNION ALL
         SELECT ''::text AS origin,
            user_notifications.user_id,
            user_notifications.template_name,
            user_notifications.created_at,
            user_notifications.sent_at,
            user_notifications.deliver_at
           FROM user_notifications
        UNION ALL
         SELECT p.name AS origin,
            pn.user_id,
            pn.template_name,
            pn.created_at,
            pn.sent_at,
            pn.deliver_at
           FROM (project_notifications pn
             JOIN projects p ON ((p.id = pn.project_id)))
        UNION ALL
         SELECT to_char(ut.amount, 'L 999G990D00'::text) AS origin,
            tn.user_id,
            tn.template_name,
            tn.created_at,
            tn.sent_at,
            tn.deliver_at
           FROM (user_transfer_notifications tn
             JOIN user_transfers ut ON ((ut.id = tn.user_transfer_id)))
        UNION ALL
         SELECT p.name AS origin,
            ppn.user_id,
            ppn.template_name,
            ppn.created_at,
            ppn.sent_at,
            ppn.deliver_at
           FROM ((project_post_notifications ppn
             JOIN project_posts pp ON ((pp.id = ppn.project_post_id)))
             JOIN projects p ON ((p.id = pp.project_id)))
        UNION ALL
         SELECT p.name AS origin,
            cn.user_id,
            cn.template_name,
            cn.created_at,
            cn.sent_at,
            cn.deliver_at
           FROM ((contribution_notifications cn
             JOIN contributions co ON ((co.id = cn.contribution_id)))
             JOIN projects p ON ((p.id = co.project_id)))) n;
    grant select on "1".notifications to admin;
    }
  end
end
