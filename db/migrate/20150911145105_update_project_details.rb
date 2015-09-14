class UpdateProjectDetails < ActiveRecord::Migration
  def up
    execute <<-SQL
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
            select
              json_build_object('id', u.id, 'name', u.name)
            from users u where u.id = p.user_id
          ) as user,
          -- json_agg(DISTINCT rd.*) as rewards,
          count(DISTINCT pn.*) filter (where pn.template_name = 'reminder') as reminder_count
        from projects p
        join categories c on c.id = p.category_id
        left join "1".project_totals pt on pt.project_id = p.id
        -- left join "1".reward_details rd on rd.project_id = p.id
        left join public.project_notifications pn on pn.project_id = p.id
        group by
          p.id,
          c.id,
          c.name_pt,
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

      create function public.has_published_projects(users) returns boolean
      language sql security definer as $$
      	select true from projects p where p.is_published and p.user_id = $1.id
      $$;

      create or replace view "1".user_details as
        select
        	u.id,
        	u.name,
        	u.address_city,
          u.profile_img_thumbnail,
          u.facebook_link,
          u.twitter as twitter_username,
        	(
        		case
            when current_user = 'anonymous' then null
        		when public.is_owner_or_admin(u.id) or u.has_published_projects then u.email
        		else null
        		end
        	) as email,
        	count(distinct c.project_id) filter (where c.state = any(public.confirmed_states())) as total_contributed_projects,
        	count(p.id) filter (where p.is_published) as total_published_projects,
        	json_agg(distinct ul.link) as links
        from users u
        left join user_links ul on ul.user_id = u.id
        left join contribution_details c on c.user_id = u.id
        left join projects p on p.user_id = u.id
        group by u.id;

      grant select on "1".user_details to admin;
      grant select on "1".user_details to web_user;
      grant select on "1".user_details to anonymous;
    SQL
  end

  def down
    execute <<-SQL
      drop view if exists "1".user_details;
      drop function if exists public.has_published_projects(users);
      drop view "1".project_details;
      create view "1".project_details as
        select
          p.id as project_id,
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
          p.remaining_time_json as remaining_time,
          (
            select
              json_build_object('id', u.id, 'name', u.name)
            from users u where u.id = p.user_id
          ) as user,
          json_agg(DISTINCT rd.*) as rewards,
          count(DISTINCT pn.*) filter (where pn.template_name = 'reminder') as reminder_count
        from projects p
        left join "1".project_totals pt on pt.project_id = p.id
        left join "1".reward_details rd on rd.project_id = p.id
        left join public.project_notifications pn on pn.project_id = p.id
        group by
          p.id,
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
