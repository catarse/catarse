class RenameProfileImgThumbnailToThumbnailImage < ActiveRecord::Migration
  def up
    execute <<-SQL
      DROP VIEW IF EXISTS "1".contribution_details2;

      CREATE OR REPLACE FUNCTION public.thumbnail_image(users)
       RETURNS text
       LANGUAGE sql
       STABLE SECURITY DEFINER
      AS $function$
            SELECT
              'https://' || (SELECT value FROM settings WHERE name = 'aws_host') ||
              '/' || (SELECT value FROM settings WHERE name = 'aws_bucket') ||
              '/uploads/user/uploaded_image/' || $1.id::text ||
              '/thumb_avatar_' || $1.uploaded_image
            $function$;

      CREATE OR REPLACE FUNCTION public.thumbnail_image(projects)
       RETURNS text
       LANGUAGE sql
       STABLE
      AS $function$
          SELECT
            'https://' || (SELECT value FROM settings WHERE name = 'aws_host') ||
            '/' || (SELECT value FROM settings WHERE name = 'aws_bucket') ||
            '/uploads/project/uploaded_image/' || $1.id::text ||
            '/project_thumb_small_' || $1.uploaded_image
          $function$;

      create or replace function public.notify_about_confirmed_payments() returns trigger
      language plpgsql as $$
        declare
          v_contribution json;
        begin
          v_contribution := (select
              json_build_object(
                'user_image', u.thumbnail_image,
                'user_name', u.name,
                'project_image', p.thumbnail_image,
                'project_name', p.name)
              from contributions c
              join users u on u.id = c.user_id
              join projects p on p.id = c.project_id
              where not c.anonymous and c.id = new.contribution_id);

          if v_contribution is not null then
            perform pg_notify('new_paid_contributions', v_contribution::text);
          end if;

          return null;
        end;
      $$;

      create or replace view "1".project_contributions as
        select
          c.anonymous,
          c.project_id as project_id,
          c.id,
          u.thumbnail_image as profile_img_thumbnail,
          u.id as user_id,
          u.name as user_name,
          (
            case
            when public.is_owner_or_admin(p.user_id) then c.value
            else null end
          ) as value,
          pa.waiting_payment,
          public.is_owner_or_admin(p.user_id) as is_owner_or_admin,
          ut.total_contributed_projects,
          c.created_at
        from contributions c
        join users u on c.user_id = u.id
        join projects p on p.id = c.project_id
        join payments pa on pa.contribution_id = c.id
        left join "1".user_totals ut on ut.user_id = u.id
        where (c.was_confirmed or pa.waiting_payment) and (not c.anonymous or public.is_owner_or_admin(p.user_id)); -- or c.waiting_payment;

      CREATE OR REPLACE VIEW "1".team_members AS
         SELECT u.id,
            u.name,
            u.thumbnail_image AS img,
            COALESCE(ut.total_contributed_projects, 0::bigint) AS total_contributed_projects,
            COALESCE(ut.sum, 0::numeric) AS total_amount_contributed
           FROM public.users u
             LEFT JOIN "1".user_totals ut ON ut.user_id = u.id
          WHERE u.admin
          ORDER BY u.name;

      CREATE OR REPLACE VIEW "1".user_details AS
         SELECT u.id,
            u.name,
            u.address_city,
            u.thumbnail_image AS profile_img_thumbnail,
            u.facebook_link,
            u.twitter AS twitter_username,
                CASE
                    WHEN "current_user"() = 'anonymous'::name THEN NULL::text
                    WHEN is_owner_or_admin(u.id) OR has_published_projects(u.*) THEN u.email
                    ELSE NULL::text
                END AS email,
            COALESCE(ut.total_contributed_projects, 0::bigint) AS total_contributed_projects,
            COALESCE(ut.total_published_projects, 0::bigint) AS total_published_projects,
            ( SELECT json_agg(DISTINCT ul.link) AS json_agg
                   FROM user_links ul
                  WHERE ul.user_id = u.id) AS links
           FROM public.users u
             LEFT JOIN "1".user_totals ut ON ut.user_id = u.id;

      CREATE OR REPLACE VIEW "1".contribution_details AS
            SELECT pa.id,
                c.id AS contribution_id,
                pa.id AS payment_id,
                c.user_id,
                c.project_id,
                c.reward_id,
                p.permalink,
                p.name AS project_name,
                p.thumbnail_image AS project_img,
                p.online_date AS project_online_date,
                p.expires_at AS project_expires_at,
                p.state AS project_state,
                u.name AS user_name,
                u.thumbnail_image AS user_profile_img,
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
                pa.deleted_at,
                pa.chargeback_at,
                pa.full_text_index,
                pa.waiting_payment,
                row_to_json(r.*) AS reward
               FROM public.projects p
                 JOIN public.contributions c ON c.project_id = p.id
                 JOIN public.payments pa ON c.id = pa.contribution_id
                 JOIN public.users u ON c.user_id = u.id
                 LEFT JOIN "1".reward_details r ON r.id = c.reward_id;
      DROP FUNCTION public.profile_img_thumbnail(users);
      DROP FUNCTION public.img_thumbnail(projects);
    SQL
  end

  def down
    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.profile_img_thumbnail(users)
       RETURNS text
       LANGUAGE sql
       STABLE SECURITY DEFINER
      AS $function$
            SELECT
              'https://' || (SELECT value FROM settings WHERE name = 'aws_host') ||
              '/' || (SELECT value FROM settings WHERE name = 'aws_bucket') ||
              '/uploads/user/uploaded_image/' || $1.id::text ||
              '/thumb_avatar_' || $1.uploaded_image
            $function$;

      CREATE OR REPLACE FUNCTION public.img_thumbnail(projects)
       RETURNS text
       LANGUAGE sql
       STABLE
      AS $function$
          SELECT
            'https://' || (SELECT value FROM settings WHERE name = 'aws_host') ||
            '/' || (SELECT value FROM settings WHERE name = 'aws_bucket') ||
            '/uploads/project/uploaded_image/' || $1.id::text ||
            '/project_thumb_small_' || $1.uploaded_image
          $function$;

      create or replace function public.notify_about_confirmed_payments() returns trigger
      language plpgsql as $$
        declare
          v_contribution json;
        begin
          v_contribution := (select
              json_build_object(
                'user_image', u.profile_img_thumbnail,
                'user_name', u.name,
                'project_image', p.img_thumbnail,
                'project_name', p.name)
              from contributions c
              join users u on u.id = c.user_id
              join projects p on p.id = c.project_id
              where not c.anonymous and c.id = new.contribution_id);

          if v_contribution is not null then
            perform pg_notify('new_paid_contributions', v_contribution::text);
          end if;

          return null;
        end;
      $$;

      create or replace view "1".project_contributions as
        select
          c.anonymous,
          c.project_id as project_id,
          c.id,
          u.profile_img_thumbnail as profile_img_thumbnail,
          u.id as user_id,
          u.name as user_name,
          (
            case
            when public.is_owner_or_admin(p.user_id) then c.value
            else null end
          ) as value,
          pa.waiting_payment,
          public.is_owner_or_admin(p.user_id) as is_owner_or_admin,
          ut.total_contributed_projects,
          c.created_at
        from contributions c
        join users u on c.user_id = u.id
        join projects p on p.id = c.project_id
        join payments pa on pa.contribution_id = c.id
        left join "1".user_totals ut on ut.user_id = u.id
        where (c.was_confirmed or pa.waiting_payment) and (not c.anonymous or public.is_owner_or_admin(p.user_id)); -- or c.waiting_payment;

      CREATE OR REPLACE VIEW "1".team_members AS
         SELECT u.id,
            u.name,
            u.profile_img_thumbnail AS img,
            COALESCE(ut.total_contributed_projects, 0::bigint) AS total_contributed_projects,
            COALESCE(ut.sum, 0::numeric) AS total_amount_contributed
           FROM public.users u
             LEFT JOIN "1".user_totals ut ON ut.user_id = u.id
          WHERE u.admin
          ORDER BY u.name;

      CREATE OR REPLACE VIEW "1".user_details AS
         SELECT u.id,
            u.name,
            u.address_city,
            u.profile_img_thumbnail AS profile_img_thumbnail,
            u.facebook_link,
            u.twitter AS twitter_username,
                CASE
                    WHEN "current_user"() = 'anonymous'::name THEN NULL::text
                    WHEN is_owner_or_admin(u.id) OR has_published_projects(u.*) THEN u.email
                    ELSE NULL::text
                END AS email,
            COALESCE(ut.total_contributed_projects, 0::bigint) AS total_contributed_projects,
            COALESCE(ut.total_published_projects, 0::bigint) AS total_published_projects,
            ( SELECT json_agg(DISTINCT ul.link) AS json_agg
                   FROM user_links ul
                  WHERE ul.user_id = u.id) AS links
           FROM public.users u
             LEFT JOIN "1".user_totals ut ON ut.user_id = u.id;


      CREATE OR REPLACE VIEW "1".contribution_details AS
        SELECT pa.id,
            c.id AS contribution_id,
            pa.id AS payment_id,
            c.user_id,
            c.project_id,
            c.reward_id,
            p.permalink,
            p.name AS project_name,
            img_thumbnail(p.*) AS project_img,
            p.online_date AS project_online_date,
            p.expires_at AS project_expires_at,
            p.state AS project_state,
            u.name AS user_name,
            profile_img_thumbnail(u.*) AS user_profile_img,
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
            pa.created_at,
            pa.created_at AS pending_at,
            pa.paid_at,
            pa.refused_at,
            pa.pending_refund_at,
            pa.refunded_at,
            pa.deleted_at,
            pa.chargeback_at,
            pa.full_text_index,
            waiting_payment(pa.*) AS waiting_payment,
            row_to_json(r.*) AS reward
           FROM public.projects p
             JOIN public.contributions c ON c.project_id = p.id
             JOIN public.payments pa ON c.id = pa.contribution_id
             JOIN public.users u ON c.user_id = u.id
             LEFT JOIN "1".reward_details r ON r.id = c.reward_id;
      DROP FUNCTION public.thumbnail_image(users);
      DROP FUNCTION public.thumbnail_image(projects);
    SQL
  end
end
