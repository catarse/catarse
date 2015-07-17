class AddRewardValueAndIsSecondSlipToContributionDetails < ActiveRecord::Migration
  def up
    execute <<-SQL
    DROP MATERIALIZED VIEW public.contributor_numbers;
    DROP VIEW "1".contribution_details;
    CREATE OR REPLACE VIEW "1".contribution_details AS
     SELECT pa.id,
    c.id AS contribution_id,
    pa.id AS payment_id,
    c.is_second_slip,
    c.user_id,
    c.project_id,
    c.reward_id,
    r.minimum_value as reward_minimum_value,
    p.permalink,
    p.name AS project_name,
    p.img_thumbnail AS project_img,
    p.online_date AS project_online_date,
    p.expires_at AS project_expires_at,
    u.name AS user_name,
    u.profile_img_thumbnail AS user_profile_img,
    u.email,
    pa.key,
    pa.value,
    pa.installments,
    pa.installment_value,
    pa.state,
    c.anonymous,
    c.payer_email,
    pa.gateway,
    pa.gateway_id,
    pa.gateway_fee,
    pa.gateway_data,
    pa.payment_method,
    p.state AS project_state,
    (EXISTS ( SELECT 1
           FROM rewards r
          WHERE r.id = c.reward_id)) AS has_rewards,
    pa.created_at,
    pa.created_at AS pending_at,
    pa.paid_at,
    pa.refused_at,
    pa.pending_refund_at,
    pa.refunded_at,
    pa.full_text_index
   FROM projects p
     JOIN contributions c ON c.project_id = p.id
     JOIN payments pa ON c.id = pa.contribution_id
     JOIN users u ON c.user_id = u.id
     LEFT JOIN rewards r ON r.id = c.reward_id;
    CREATE MATERIALIZED VIEW public.contributor_numbers AS
     WITH confirmed AS (
         SELECT c.user_id,
            min(c.id) AS id
           FROM "1".contribution_details c
          WHERE c.state = ANY (confirmed_states())
          GROUP BY c.user_id
          ORDER BY min(c.id)
        )
 SELECT confirmed.user_id,
    row_number() OVER (ORDER BY confirmed.id) AS number
   FROM confirmed;
   GRANT select ON ALL TABLES IN SCHEMA "1" TO admin;
   GRANT SELECT on settings to admin;
    SQL
  end
  def down
    execute <<-SQL
    DROP MATERIALIZED VIEW public.contributor_numbers;
    DROP VIEW "1".contribution_details;
    CREATE OR REPLACE VIEW "1".contribution_details AS
     SELECT pa.id,
    c.id AS contribution_id,
    pa.id AS payment_id,
    c.user_id,
    c.project_id,
    c.reward_id,
    p.permalink,
    p.name AS project_name,
    p.img_thumbnail AS project_img,
    p.online_date AS project_online_date,
    p.expires_at AS project_expires_at,
    u.name AS user_name,
    u.profile_img_thumbnail AS user_profile_img,
    u.email,
    pa.key,
    pa.value,
    pa.installments,
    pa.installment_value,
    pa.state,
    c.anonymous,
    c.payer_email,
    pa.gateway,
    pa.gateway_id,
    pa.gateway_fee,
    pa.gateway_data,
    pa.payment_method,
    p.state AS project_state,
    (EXISTS ( SELECT 1
           FROM rewards r
          WHERE r.id = c.reward_id)) AS has_rewards,
    pa.created_at,
    pa.created_at AS pending_at,
    pa.paid_at,
    pa.refused_at,
    pa.pending_refund_at,
    pa.refunded_at,
    pa.full_text_index
   FROM projects p
     JOIN contributions c ON c.project_id = p.id
     JOIN payments pa ON c.id = pa.contribution_id
     JOIN users u ON c.user_id = u.id;
    CREATE MATERIALIZED VIEW public.contributor_numbers AS
     WITH confirmed AS (
         SELECT c.user_id,
            min(c.id) AS id
           FROM "1".contribution_details c
          WHERE c.state = ANY (confirmed_states())
          GROUP BY c.user_id
          ORDER BY min(c.id)
        )
 SELECT confirmed.user_id,
    row_number() OVER (ORDER BY confirmed.id) AS number
   FROM confirmed;
   GRANT select ON ALL TABLES IN SCHEMA "1" TO admin;
   GRANT SELECT on settings to admin;
    SQL
  end
end
