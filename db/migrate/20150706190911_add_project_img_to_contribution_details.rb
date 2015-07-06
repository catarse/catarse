class AddProjectImgToContributionDetails < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE OR REPLACE FUNCTION public.img_thumbnail(projects) RETURNS text AS $$ 
    SELECT 
      'https://' || (SELECT value FROM settings WHERE name = 'aws_host') || 
      '/' || (SELECT value FROM settings WHERE name = 'aws_bucket') ||
      '/uploads/project/uploaded_image/' || $1.id::text ||
      '/project_thumb_small_' || $1.uploaded_image
    $$ LANGUAGE SQL STABLE;

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
    (
      p.permalink
      || ' ' || p.name ||
      coalesce(' ' || u.name, '') ||
      coalesce(' ' || u.email, '') ||
      coalesce(' ' || pa.key, '') ||
      coalesce(' ' || c.payer_email, '') ||
      coalesce(' ' || pa.gateway_id, '') ||
      coalesce(' ' || (pa.gateway_data->>'acquirer_name'), '') || 
      coalesce(' ' || (pa.gateway_data->>'card_brand'), '') || 
      coalesce(' ' || (pa.gateway_data->>'tid'), '')
    ) AS search_text
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
    u.name AS user_name,
    u.profile_img_thumbnail AS user_profile_img,
    u.email,
    u.uploaded_image,
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
    pa.refunded_at
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
    SQL
  end
end
