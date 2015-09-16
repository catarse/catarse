class AddProjectContributionsView < ActiveRecord::Migration
  def up
    execute <<-SQL
      drop view "1".user_details;
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
          ut.total_contributed_projects,
        	count(p.id) filter (where p.is_published) as total_published_projects,
        	json_agg(distinct ul.link) as links
        from users u
        left join user_links ul on ul.user_id = u.id
        left join user_totals ut on ut.user_id = u.id
        left join projects p on p.user_id = u.id
        group by u.id, ut.total_contributed_projects;

      grant select on "1".user_details to admin;
      grant select on "1".user_details to web_user;
      grant select on "1".user_details to anonymous;

      create view "1".project_contributions as
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

      grant select on "1".project_contributions to admin;
      grant select on "1".project_contributions to web_user;
      grant select on "1".project_contributions to anonymous;
    SQL
  end

  def down
    execute <<-SQL
      drop view "1".project_contributions;
      drop view "1".user_details;
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
end
