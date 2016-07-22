class AddContributorsEndpoint < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE VIEW "1".contributors AS 
select
    u.id as id,
    u.id as user_id,
    c.project_id as project_id,
    json_build_object(
        'profile_img_thumbnail', public.thumbnail_image(u.*),
        'name', u.name,
        'city', u.address_city,
        'state', u.address_state,
        'total_contributed_projects', ut.total_contributed_projects,
        'total_published_projects', ut.total_published_projects
    ) as data
from public.contributions c
join public.users u on u.id = c.user_id
join public.projects p on p.id = c.project_id
join "1".user_totals ut on ut.user_id = u.id
where (case when p.state = 'failed' then c.was_confirmed else c.is_confirmed end)
    and not c.anonymous
    and u.deactivated_at is null
group by u.id, c.project_id, ut.total_contributed_projects, ut.total_published_projects;

GRANT SELECT ON "1".contributors TO admin, anonymous, web_user;
    }
  end

  def down
    execute %Q{
DROP VIEW "1".contributors;
    }
  end
end
