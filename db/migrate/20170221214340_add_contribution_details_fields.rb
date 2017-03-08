class AddContributionDetailsFields < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE OR REPLACE VIEW "1".contribution_details AS
     SELECT pa.id,
        c.id AS contribution_id,
        pa.id AS payment_id,
        c.user_id,
        c.project_id,
        c.reward_id,
        p.permalink,
        p.name AS project_name,
        public.thumbnail_image(p.*) AS project_img,
        public.zone_timestamp(public.online_at(p.*)) AS project_online_date,
        public.zone_timestamp(p.expires_at) AS project_expires_at,
        p.state AS project_state,
        u.name AS user_name,
        public.thumbnail_image(u.*) AS user_profile_img,
        u.email,
        c.anonymous,
        c.payer_email,
        pa.key,
        pa.value,
        pa.installments,
        pa.installment_value,
        pa.state,
        public.is_second_slip(pa.*) AS is_second_slip,
        pa.gateway,
        pa.gateway_id,
        pa.gateway_fee,
        pa.gateway_data,
        pa.payment_method,
        public.zone_timestamp(pa.created_at) AS created_at,
        public.zone_timestamp(pa.created_at) AS pending_at,
        public.zone_timestamp(pa.paid_at) AS paid_at,
        public.zone_timestamp(pa.refused_at) AS refused_at,
        public.zone_timestamp(pa.pending_refund_at) AS pending_refund_at,
        public.zone_timestamp(pa.refunded_at) AS refunded_at,
        public.zone_timestamp(pa.deleted_at) AS deleted_at,
        public.zone_timestamp(pa.chargeback_at) AS chargeback_at,
        pa.full_text_index,
        public.waiting_payment(pa.*) AS waiting_payment,
        c.delivery_status
       FROM (((public.projects p
         JOIN public.contributions c ON ((c.project_id = p.id)))
         JOIN public.payments pa ON ((c.id = pa.contribution_id)))
         JOIN public.users u ON ((c.user_id = u.id)));

    GRANT select ON "1".contribution_details TO admin;
    GRANT update ON "1".contribution_details TO admin;
    SQL
  end
  def down
    execute <<-SQL
    DROP VIEW "1".contribution_details CASCADE;
    CREATE OR REPLACE VIEW "1".contribution_details AS
     SELECT pa.id,
        c.id AS contribution_id,
        pa.id AS payment_id,
        c.user_id,
        c.project_id,
        c.reward_id,
        p.permalink,
        p.name AS project_name,
        public.thumbnail_image(p.*) AS project_img,
        public.zone_timestamp(public.online_at(p.*)) AS project_online_date,
        public.zone_timestamp(p.expires_at) AS project_expires_at,
        p.state AS project_state,
        u.name AS user_name,
        public.thumbnail_image(u.*) AS user_profile_img,
        u.email,
        c.anonymous,
        c.payer_email,
        pa.key,
        pa.value,
        pa.installments,
        pa.installment_value,
        pa.state,
        public.is_second_slip(pa.*) AS is_second_slip,
        pa.gateway,
        pa.gateway_id,
        pa.gateway_fee,
        pa.gateway_data,
        pa.payment_method,
        public.zone_timestamp(pa.created_at) AS created_at,
        public.zone_timestamp(pa.created_at) AS pending_at,
        public.zone_timestamp(pa.paid_at) AS paid_at,
        public.zone_timestamp(pa.refused_at) AS refused_at,
        public.zone_timestamp(pa.pending_refund_at) AS pending_refund_at,
        public.zone_timestamp(pa.refunded_at) AS refunded_at,
        public.zone_timestamp(pa.deleted_at) AS deleted_at,
        public.zone_timestamp(pa.chargeback_at) AS chargeback_at,
        pa.full_text_index,
        public.waiting_payment(pa.*) AS waiting_payment
       FROM (((public.projects p
         JOIN public.contributions c ON ((c.project_id = p.id)))
         JOIN public.payments pa ON ((c.id = pa.contribution_id)))
         JOIN public.users u ON ((c.user_id = u.id)));

    GRANT select ON "1".contribution_details TO admin;
    GRANT update ON "1".contribution_details TO admin;
    SQL
  end
end
