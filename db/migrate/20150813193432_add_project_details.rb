class AddProjectDetails < ActiveRecord::Migration
  def up
    current_database = execute("SELECT current_database();")[0]["current_database"]
    execute <<-SQL
      alter database #{current_database} set user_vars.user_id = '';

      create function public.is_owner_or_admin(integer) returns boolean
      language sql STABLE SECURITY DEFINER
      AS $_$
        SELECT
          current_setting('user_vars.user_id') = $1::text
          OR current_user = 'admin';
      $_$;

      drop view "1".reward_details cascade;
      CREATE VIEW "1".reward_details AS
       SELECT r.id,
          r.project_id,
          r.description,
          r.minimum_value,
          r.maximum_contributions,
          r.deliver_at,
          r.updated_at,
          public.paid_count(r.*) AS paid_count,
          public.waiting_payment_count(r.*) AS waiting_payment_count
         FROM public.rewards r;

      CREATE VIEW contribution_details AS
       SELECT pa.id,
          c.id AS contribution_id,
          pa.id AS payment_id,
          c.user_id,
          c.project_id,
          c.reward_id,
          p.permalink,
          p.name AS project_name,
          public.img_thumbnail(p.*) AS project_img,
          p.online_date AS project_online_date,
          p.expires_at AS project_expires_at,
          p.state AS project_state,
          u.name AS user_name,
          public.profile_img_thumbnail(u.*) AS user_profile_img,
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
          pa.created_at,
          pa.created_at AS pending_at,
          pa.paid_at,
          pa.refused_at,
          pa.pending_refund_at,
          pa.refunded_at,
          pa.deleted_at,
          pa.chargeback_at,
          pa.full_text_index,
          public.waiting_payment(pa.*) AS waiting_payment,
          row_to_json(r.*) AS reward
         FROM ((((public.projects p
           JOIN public.contributions c ON ((c.project_id = p.id)))
           JOIN public.payments pa ON ((c.id = pa.contribution_id)))
           JOIN public.users u ON ((c.user_id = u.id)))
           LEFT JOIN "1".reward_details r ON ((r.id = c.reward_id)));

      create view "1".project_details as
        select
          pt.*,
          p.state,
          p.expires_at,
          json_agg(row_to_json(rd.*)) as rewards
        from projects p
        left join "1".project_totals pt on pt.project_id = p.id
        left join "1".reward_details rd on rd.project_id = p.id
        group by
          pt.project_id,
          pt.progress,
          pt.pledged,
          pt.total_contributions,
          p.state,
          p.expires_at,
          pt.total_payment_service_fee;

      grant select on "1".project_details to admin;
      grant select on "1".project_details to web_user;
      grant select on "1".project_details to anonymous;
    SQL
  end

  def down
    execute <<-SQL
      revoke select on "1".project_details from admin;
      revoke select on "1".project_details from web_user;
      revoke select on "1".project_details from anonymous;
      drop function public.is_owner_or_admin(integer);
      drop view  IF EXISTS "1".project_details;

     drop view "1".reward_details cascade;
      CREATE VIEW "1".reward_details AS
       SELECT r.id,
          r.description,
          r.minimum_value,
          r.maximum_contributions,
          r.deliver_at,
          r.updated_at,
          public.paid_count(r.*) AS paid_count,
          public.waiting_payment_count(r.*) AS waiting_payment_count
         FROM public.rewards r;

      CREATE VIEW contribution_details AS
       SELECT pa.id,
          c.id AS contribution_id,
          pa.id AS payment_id,
          c.user_id,
          c.project_id,
          c.reward_id,
          p.permalink,
          p.name AS project_name,
          public.img_thumbnail(p.*) AS project_img,
          p.online_date AS project_online_date,
          p.expires_at AS project_expires_at,
          p.state AS project_state,
          u.name AS user_name,
          public.profile_img_thumbnail(u.*) AS user_profile_img,
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
          pa.created_at,
          pa.created_at AS pending_at,
          pa.paid_at,
          pa.refused_at,
          pa.pending_refund_at,
          pa.refunded_at,
          pa.deleted_at,
          pa.chargeback_at,
          pa.full_text_index,
          public.waiting_payment(pa.*) AS waiting_payment,
          row_to_json(r.*) AS reward
         FROM ((((public.projects p
           JOIN public.contributions c ON ((c.project_id = p.id)))
           JOIN public.payments pa ON ((c.id = pa.contribution_id)))
           JOIN public.users u ON ((c.user_id = u.id)))
           LEFT JOIN "1".reward_details r ON ((r.id = c.reward_id)));

    SQL
  end
end
