class AddProjectPostsDetailsView < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE FUNCTION original_image(projects) RETURNS text
    LANGUAGE sql STABLE
    AS $_$
          SELECT
            'https://' || settings('aws_host')  ||
            '/' || settings('aws_bucket') ||
            '/uploads/project/uploaded_image/' || $1.id::text ||
             '/' || $1.uploaded_image
      $_$;

      create function public.user_has_contributed_to_project(user_id integer, project_id integer) 
      returns boolean
      language sql 
      security definer 
      stable
      as $$
        select true from "1".contribution_details c where c.state = any(public.confirmed_states()) and c.project_id = $2 and c.user_id = $1;
      $$;

      create function public.current_user_has_contributed_to_project(integer) 
      returns boolean
      language sql
      stable
      as $$
        select public.user_has_contributed_to_project(nullif(current_setting('user_vars.user_id'), '')::int, $1);
      $$;

      drop view "1".project_details;
      create view "1".project_details as
        select
          p.id as project_id,
          p.id,
          p.user_id,
          p.name,
          p.headline,
          p.budget,
          p.goal,
          p.about_html,
          p.permalink,
          p.video_embed_url,
          p.video_url,
          c.name_pt as category_name,
          c.id as category_id,
          p.original_image AS original_image,
          public.img_thumbnail(p.*,'thumb') AS thumb_image,
          public.img_thumbnail(p.*,'small') AS small_image,
          public.img_thumbnail(p.*,'large') AS large_image,
          public.img_thumbnail(p.*,'video_cover') AS video_cover_image,
          coalesce(pt.progress, 0) as progress,
          coalesce(pt.pledged, 0) as pledged,
          coalesce(pt.total_contributions, 0) as total_contributions,
          p.state,
          p.expires_at,
          p.zone_expires_at,
          p.online_date,
          p.sent_to_analysis_at,
          p.is_published,
          p.is_expired,
          p.open_for_contributions,
          p.online_days,
          p.remaining_time_json as remaining_time,
          (select count(pp.*) from project_posts pp where pp.project_id = p.id) as posts_count,
          (
            json_build_object('city', coalesce(ct.name, u.address_city), 'state_acronym', coalesce(st.acronym, u.address_state), 'state', coalesce(st.name, u.address_state))
          ) as address,
          (
            json_build_object('id', u.id, 'name', u.name)
          ) as user,
          count(DISTINCT pn.*) filter (where pn.template_name = 'reminder') as reminder_count,
          public.is_owner_or_admin(p.user_id) as is_owner_or_admin
        from projects p
        join categories c on c.id = p.category_id
        join users u on u.id = p.user_id
        left join "1".project_totals pt on pt.project_id = p.id
        left join public.cities ct on ct.id = p.city_id
        left join public.states st on st.id = ct.state_id
        left join public.project_notifications pn on pn.project_id = p.id
        group by
          p.id,
          c.id,
          u.id,
          c.name_pt,
          ct.name,
          u.address_city,
          st.acronym,
          u.address_state,
          st.name,
          pt.progress,
          pt.pledged,
          pt.total_contributions,
          p.state,
          p.expires_at,
          p.sent_to_analysis_at,
          pt.total_payment_service_fee;

      grant select on "1".project_details to admin;
      grant select on "1".project_details to web_user;
      grant select on "1".project_details to anonymous;

      create view "1".project_posts_details as
        select
          pp.id,
          pp.project_id,
          public.is_owner_or_admin(p.user_id) as is_owner_or_admin,
          pp.exclusive,
          pp.title,
          (
            case
            when not pp.exclusive then pp.comment_html
            when pp.exclusive and (public.is_owner_or_admin(p.user_id) or public.current_user_has_contributed_to_project(p.id)) then pp.comment_html
            else null end
          ) as comment_html,
          pp.created_at
        from project_posts pp
        join projects p on p.id = pp.project_id;

      grant select on "1".project_posts_details to admin;
      grant select on "1".project_posts_details to web_user;
      grant select on "1".project_posts_details to anonymous;
    SQL
  end

  def down
    execute <<-SQL
      drop FUNCTION if exists original_image(projects);
      drop view "1".project_details;
      create view "1".project_details as
        select
          p.id as project_id,
          p.id,
          p.user_id,
          p.name,
          p.headline,
          p.budget,
          p.goal,
          p.about_html,
          p.permalink,
          p.video_embed_url,
          p.video_url,
          c.name_pt as category_name,
          c.id as category_id,
          coalesce(pt.progress, 0) as progress,
          coalesce(pt.pledged, 0) as pledged,
          coalesce(pt.total_contributions, 0) as total_contributions,
          p.state,
          p.expires_at,
          p.zone_expires_at,
          p.online_date,
          p.sent_to_analysis_at,
          p.is_published,
          p.is_expired,
          p.open_for_contributions,
          p.online_days,
          p.remaining_time_json as remaining_time,
          (select count(pp.*) from project_posts pp where pp.project_id = p.id) as posts_count,
          (
            json_build_object('city', coalesce(ct.name, u.address_city), 'state_acronym', coalesce(st.acronym, u.address_state), 'state', coalesce(st.name, u.address_state))
          ) as address,
          (
            json_build_object('id', u.id, 'name', u.name)
          ) as user,
          count(DISTINCT pn.*) filter (where pn.template_name = 'reminder') as reminder_count,
          public.is_owner_or_admin(p.user_id) as is_owner_or_admin
        from projects p
        join categories c on c.id = p.category_id
        join users u on u.id = p.user_id
        left join "1".project_totals pt on pt.project_id = p.id
        left join public.cities ct on ct.id = p.city_id
        left join public.states st on st.id = ct.state_id
        left join public.project_notifications pn on pn.project_id = p.id
        group by
          p.id,
          c.id,
          u.id,
          c.name_pt,
          ct.name,
          u.address_city,
          st.acronym,
          u.address_state,
          st.name,
          pt.progress,
          pt.pledged,
          pt.total_contributions,
          p.state,
          p.expires_at,
          p.sent_to_analysis_at,
          pt.total_payment_service_fee;

      grant select on "1".project_details to admin;
      grant select on "1".project_details to web_user;
      grant select on "1".project_details to anonymous;

      drop view "1".project_posts_details;
      drop function if exists public.user_has_contributed_to_project(user_id integer, project_id integer);
      drop function if exists public.current_user_has_contributed_to_project(integer);
    SQL
  end
end
