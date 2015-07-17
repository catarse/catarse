class AddIsSecondSlipFunctionAndAdjustContributionDetails < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.is_second_slip(payments) RETURNS boolean
        LANGUAGE sql AS $_$
          SELECT lower($1.payment_method) = 'boletobancario' and EXISTS (select true from payments p
               where p.contribution_id = $1.contribution_id
               and p.id < $1.id
               and lower(p.payment_method) = 'boletobancario')
        $_$ STABLE;

    DROP VIEW "1".contribution_details;
    CREATE OR REPLACE VIEW "1".contribution_details AS
     SELECT
        pa.id,
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
        p.state AS project_state,
        u.name AS user_name,
        u.profile_img_thumbnail AS user_profile_img,
        u.email,
        c.anonymous,
        c.payer_email,
        pa.key,
        pa.value,
        pa.installments,
        pa.installment_value,
        pa.state,
        pa.is_second_slip,
        pa.gateway,
        pa.gateway_id,
        pa.gateway_fee,
        pa.gateway_data,
        pa.payment_method,
        pa.created_at,
        pa.created_at AS pending_at,
        pa.paid_at,
        pa.refused_at,
        pa.pending_refund_at,
        pa.refunded_at,
        pa.full_text_index,
        (r.id IS NOT NULL) as has_rewards,
        r.minimum_value as reward_minimum_value
        FROM projects p
         JOIN contributions c ON c.project_id = p.id
         JOIN payments pa ON c.id = pa.contribution_id
         JOIN users u ON c.user_id = u.id
         LEFT JOIN rewards r ON r.id = c.reward_id;
       GRANT select ON ALL TABLES IN SCHEMA "1" TO admin;
       GRANT select ON payments TO admin;
    SQL
  end

  def down
    execute <<-SQL
      DROP VIEW "1".contribution_details;
      CREATE OR REPLACE VIEW "1".contribution_details AS
       SELECT
          pa.id,
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
          p.state AS project_state,
          u.name AS user_name,
          u.profile_img_thumbnail AS user_profile_img,
          u.email,
          c.anonymous,
          c.payer_email,
          pa.key,
          pa.value,
          pa.installments,
          pa.installment_value,
          pa.state,
          pa.gateway,
          pa.gateway_id,
          pa.gateway_fee,
          pa.gateway_data,
          pa.payment_method,
          pa.created_at,
          pa.created_at AS pending_at,
          pa.paid_at,
          pa.refused_at,
          pa.pending_refund_at,
          pa.refunded_at,
          pa.full_text_index,
          (r.id IS NOT NULL) as has_rewards
          FROM projects p
           JOIN contributions c ON c.project_id = p.id
           JOIN payments pa ON c.id = pa.contribution_id
           JOIN users u ON c.user_id = u.id
           LEFT JOIN rewards r ON r.id = c.reward_id;
      DROP FUNCTION public.is_second_slip(payments);
    SQL
  end
end
