class AddstatusToContributions < ActiveRecord::Migration
  def change
    execute %Q{
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
    u.public_name,
    c.delivery_status
   FROM ((((projects p
     JOIN contributions c ON ((c.project_id = p.id)))
     JOIN payments pa ON ((c.id = pa.contribution_id)))
     JOIN users u ON ((c.user_id = u.id)))
     LEFT JOIN rewards r ON ((r.id = c.reward_id)))
  WHERE is_owner_or_admin(c.user_id);



CREATE OR REPLACE VIEW "1"."project_contributions" AS 
 SELECT 
    c.anonymous,
    c.project_id,
    c.reward_id::numeric,
    (c.id)::numeric AS id,
    thumbnail_image(u.*) AS profile_img_thumbnail,
    u.id AS user_id,
    u.name AS user_name,
    c.value,
    pa.state,
    u.email,
    (row_to_json(r.*))::jsonb as reward,
    waiting_payment(pa.*) AS waiting_payment,
    is_owner_or_admin(p.user_id) AS is_owner_or_admin,
    ut.total_contributed_projects,
    zone_timestamp(c.created_at) AS created_at,
    NULL::boolean AS has_another,
    pa.full_text_index,
    c.delivery_status
   FROM (((((public.contributions c
     JOIN public.users u ON ((c.user_id = u.id)))
     JOIN public.projects p ON ((p.id = c.project_id)))
     JOIN public.payments pa ON ((pa.contribution_id = c.id)))
     LEFT JOIN "1".user_totals ut ON ((ut.id = u.id)))
     LEFT JOIN public.rewards r ON ((r.id = c.reward_id)))
  WHERE (((public.was_confirmed(c.*) and pa.state <> 'pending') OR public.waiting_payment(pa.*)) AND public.is_owner_or_admin(p.user_id));
  
}
    
  end
end
