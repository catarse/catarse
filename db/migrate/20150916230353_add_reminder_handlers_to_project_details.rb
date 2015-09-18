class AddReminderHandlersToProjectDetails < ActiveRecord::Migration
  def up
    execute <<-SQL
      create function public.user_signed_in() returns boolean
      language sql as $$
        select current_user <> 'anonymous';
      $$;

      create function public.user_has_reminder_for_project(user_id integer, project_id integer) returns boolean
      language sql security definer as $$
        select exists (select true from project_notifications pn where pn.template_name = 'reminder' and pn.user_id = $1 and pn.project_id = $2);
      $$;

      create function public.current_user_already_in_reminder(projects) returns boolean
      language sql as $$
        select public.user_has_reminder_for_project(nullif(current_setting('user_vars.user_id'), '')::integer, $1.id);
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
          public.is_owner_or_admin(p.user_id) as is_owner_or_admin,
          public.user_signed_in() as user_signed_in,
          public.current_user_already_in_reminder(p) as in_reminder,
          count(pp.*) as total_posts,
          (current_user = 'admin') as is_admin_role
        from projects p
        join categories c on c.id = p.category_id
        join users u on u.id = p.user_id
        left join public.project_posts pp on pp.project_id = p.id
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

      create view "1".project_reminders as
        select
          pn.project_id,
          pn.user_id
        from project_notifications pn
        where pn.template_name = 'reminder'
        and public.is_owner_or_admin(pn.user_id);

      grant select, insert, delete on "1".project_reminders to web_user;
      grant select, insert, delete on "1".project_reminders to admin;

      grant select, insert, delete on public.project_notifications to web_user;
      grant select, insert, delete on public.project_notifications to admin;

      grant usage on public.project_notifications_id_seq to admin;
      grant usage on public.project_notifications_id_seq to web_user;

      grant select on public.projects to web_user;
      grant select on public.projects to admin;


      create or replace function public.insert_project_reminder() returns trigger
      language plpgsql as $$
        declare
          reminder "1".project_reminders;
        begin
          select
            pn.project_id,
            pn.user_id
          from public.project_notifications pn
          where
            pn.template_name = 'reminder'
            and pn.user_id = current_setting('user_vars.user_id')::integer
            and pn.project_id = NEW.project_id
          into reminder;

          if found then
            return reminder;
          end if;

          insert into public.project_notifications (user_id, project_id, template_name, deliver_at, locale, from_email, from_name)
          values (current_setting('user_vars.user_id')::integer, NEW.project_id, 'reminder', (
            select p.expires_at - '48 hours'::interval from projects p where p.id = NEW.project_id
          ), 'pt', settings('email_contact'), settings('company_name'));

          return new;
        end;
      $$;

      create or replace function public.delete_project_reminder() returns trigger
      language plpgsql as $$
        begin
          delete from public.project_notifications where user_id = current_setting('user_vars.user_id')::integer and project_id = OLD.project_id;
          return old;
        end;
      $$;

      create trigger insert_project_reminder instead of insert on "1".project_reminders
        for each row execute procedure public.insert_project_reminder();

      create trigger delete_project_reminder instead of delete on "1".project_reminders
        for each row execute procedure public.delete_project_reminder();
    SQL
  end

  def down
    execute <<-SQL
      revoke select, insert, delete on public.project_notifications from web_user;
      revoke select, insert, delete on public.project_notifications from admin;

      revoke usage on public.project_notifications_id_seq from admin;
      revoke usage on public.project_notifications_id_seq from web_user;

      revoke select on public.projects from web_user;
      revoke select on public.projects from admin;

      drop view if exists "1".project_reminders;
      drop function if exists public.insert_project_reminder() cascade;
      drop function if exists public.delete_project_reminder() cascade;

      drop view "1".project_details;
      drop function if exists public.user_signed_in();
      drop function if exists public.user_has_reminder_for_project(user_id integer, project_id integer);
      drop function if exists public.current_user_already_in_reminder(projects);
      drop function if exists public.user_signed_in();
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
    SQL
  end
end
