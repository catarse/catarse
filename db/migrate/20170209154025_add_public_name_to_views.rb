class AddPublicNameToViews < ActiveRecord::Migration
  def change
    execute %Q{
CREATE OR REPLACE VIEW "1"."contributors" AS 
 SELECT u.id,
    u.id AS user_id,
    c.project_id,
    json_build_object('profile_img_thumbnail', thumbnail_image(u.*), 'public_name', u.public_name, 'name', u.name, 'city', u.address_city, 'state', u.address_state, 'total_contributed_projects', ut.total_contributed_projects, 'total_published_projects', ut.total_published_projects) AS data,
    (EXISTS ( SELECT true AS bool
           FROM user_follows uf
          WHERE ((uf.user_id = current_user_id()) AND (uf.follow_id = u.id)))) AS is_follow
   FROM (((contributions c
     JOIN users u ON ((u.id = c.user_id)))
     JOIN projects p ON ((p.id = c.project_id)))
     JOIN "1".user_totals ut ON ((ut.user_id = u.id)))
  WHERE (
        CASE
            WHEN ((p.state)::text = 'failed'::text) THEN was_confirmed(c.*)
            ELSE is_confirmed(c.*)
        END AND (NOT c.anonymous) AND (u.deactivated_at IS NULL))
  GROUP BY u.id, c.project_id, ut.total_contributed_projects, ut.total_published_projects;

CREATE OR REPLACE VIEW "1"."user_follows" AS 
 SELECT uf.user_id,
    uf.follow_id,
    json_build_object('public_name', f.public_name, 'name', f.name, 'avatar', thumbnail_image(f.*), 'total_contributed_projects', ut.total_contributed_projects, 'total_published_projects', ut.total_published_projects, 'city', f.address_city, 'state', f.address_state) AS source,
    zone_timestamp(uf.created_at) AS created_at
   FROM ((user_follows uf
     LEFT JOIN "1".user_totals ut ON ((ut.user_id = uf.follow_id)))
     JOIN users f ON ((f.id = uf.follow_id)))
  WHERE (is_owner_or_admin(uf.user_id) AND (f.deactivated_at IS NULL));

CREATE OR REPLACE VIEW "1"."user_contributions" AS 
 SELECT pa.id,
    c.id AS contribution_id,
    pa.id AS payment_id,
    c.user_id,
    c.project_id,
    c.reward_id,
    p.permalink,
    p.name AS project_name,
    thumbnail_image(p.*) AS project_img,
    zone_timestamp(online_at(p.*)) AS project_online_date,
    zone_timestamp(p.expires_at) AS project_expires_at,
    p.state AS project_state,
    u.name AS user_name,
    thumbnail_image(u.*) AS user_profile_img,
    u.email,
    c.anonymous,
    c.payer_email,
    pa.key,
    pa.value,
    pa.installments,
    pa.installment_value,
    pa.state,
    is_second_slip(pa.*) AS is_second_slip,
    pa.gateway,
    pa.gateway_id,
    pa.gateway_fee,
    pa.gateway_data,
    pa.payment_method,
    zone_timestamp(pa.created_at) AS created_at,
    zone_timestamp(pa.created_at) AS pending_at,
    zone_timestamp(pa.paid_at) AS paid_at,
    zone_timestamp(pa.refused_at) AS refused_at,
    zone_timestamp(pa.pending_refund_at) AS pending_refund_at,
    zone_timestamp(pa.refunded_at) AS refunded_at,
    zone_timestamp(pa.deleted_at) AS deleted_at,
    zone_timestamp(pa.chargeback_at) AS chargeback_at,
    pa.full_text_index,
    waiting_payment(pa.*) AS waiting_payment,
    (EXISTS ( SELECT true AS bool
           FROM unsubscribes un
          WHERE ((un.project_id = c.project_id) AND (un.user_id = u.id)))) AS unsubscribed,
    r.description AS reward_description,
    r.deliver_at,
    thumbnail_image(p.*, ''::text) AS project_image,
    sold_out(r.*) AS reward_sold_out,
    u.public_name
   FROM ((((projects p
     JOIN contributions c ON ((c.project_id = p.id)))
     JOIN payments pa ON ((c.id = pa.contribution_id)))
     JOIN users u ON ((c.user_id = u.id)))
     LEFT JOIN rewards r ON ((r.id = c.reward_id)))
  WHERE is_owner_or_admin(c.user_id);
}
  end
end
