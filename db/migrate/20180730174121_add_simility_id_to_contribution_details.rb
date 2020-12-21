class AddSimilityIdToContributionDetails < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL
CREATE OR REPLACE VIEW "1"."contribution_details" AS
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
    c.delivery_status,
    c.shipping_fee_id,
    o.id as simility_id
   FROM (((projects p
     JOIN contributions c ON ((c.project_id = p.id)))
     JOIN payments pa ON ((c.id = pa.contribution_id)))
     JOIN users u ON ((c.user_id = u.id))
     LEFT JOIN gateway_payments gp on gp.transaction_id=pa.gateway_id
     left join lateral (
        select string_agg(id,',') id
        from json_to_recordset(gp.operations::json) as (id text, processor text)
        where processor='simility'
    ) o on true
);
    SQL

  end
end
