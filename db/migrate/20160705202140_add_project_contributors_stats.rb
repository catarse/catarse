class AddProjectContributorsStats < ActiveRecord::Migration
  def up
    execute %{
CREATE OR REPLACE FUNCTION is_confirmed(contributions) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
      SELECT EXISTS (
        SELECT true
        FROM 
          public.payments p 
        WHERE p.contribution_id = $1.id AND p.state = 'paid'
      );
    $_$;


create or replace view "1".project_stat_contributors AS
select
        p.id as project_id,
        count(distinct c.user_id) as total,
        count(distinct c.user_id) filter(where lt.total_contributed_projects = 0) / count(distinct c.user_id)::float * 100 as new_percent,
        count(distinct c.user_id) filter(where lt.total_contributed_projects > 0) / count(distinct c.user_id)::float * 100 as returning_percent
from public.projects p
join public.contributions c on p.id = c.project_id
join lateral (
    select
        count(distinct cl.project_id) as total_contributed_projects
    from public.contributions cl
    where cl.user_id = c.user_id and cl.was_confirmed and cl.created_at <= c.created_at and cl.project_id<>p.id
) as lt on true
where 
    (case when p.state = 'failed' then c.was_confirmed else c.is_confirmed end)
group by p.id;

grant select on "1".project_stat_contributors to web_user, anonymous, admin;
    }
  end

  def down
    execute %{
CREATE OR REPLACE FUNCTION is_confirmed(contributions) RETURNS boolean
    LANGUAGE sql 
    AS $_$
      SELECT EXISTS (
        SELECT true
        FROM 
          public.payments p 
        WHERE p.contribution_id = $1.id AND p.state = 'paid'
      );
    $_$;

DROP VIEW "1".project_stat_contributors;
    }
  end
end
