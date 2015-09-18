class FixUserDetailsNullFields < ActiveRecord::Migration
  def up
    execute <<-SQL
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
          coalesce(ut.total_contributed_projects, 0) as total_contributed_projects,
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
    SQL
  end

  def down
    execute <<-SQL
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
    SQL
  end
end
