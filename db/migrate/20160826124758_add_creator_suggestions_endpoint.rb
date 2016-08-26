class AddCreatorSuggestionsEndpoint < ActiveRecord::Migration
  def up
    execute %Q{
create or replace view "1".creator_suggestions as
select
    u.id,
    u.id as user_id,
    thumbnail_image(u.*) as avatar,
    u.name as name,
    u.address_city as city,
    u.address_state as state,
    ut.total_contributed_projects as total_contributed_projects,
    ut.total_published_projects as total_published_projects,
    public.zone_timestamp(u.created_at) AS created_at,
    public.user_following_this_user(public.current_user_id(), u.id) as following
from public.contributions c
join public.projects p on p.id = c.project_id
join public.users u on u.id = p.user_id
join "1".user_totals ut on ut.user_id = u.id
where c.was_confirmed and u.id <> public.current_user_id() and c.user_id = public.current_user_id() and u.deactivated_at is null
group by u.id, ut.total_contributed_projects, ut.total_published_projects;

grant select on "1".creator_suggestions to admin, web_user;
    }
  end

  def down
    execute %Q{
DROP VIEW "1".creator_suggestions;
    }
  end
end
