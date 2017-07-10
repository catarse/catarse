class CreateRecommendApi < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE FUNCTION "1".recommend_projects2user(user_id integer)
  RETURNS SETOF "1".projects AS
$BODY$
    with sim_users as ( -- Pega X usuarios mais proximos a você
      select user1_id, user2_id, tanimoto, ru1.contributions as user1_contribs
      from public.recommend_tanimoto_users u
      join public.recommend_users ru1 on ru1.user_id=u.user1_id
      where u.user1_id=user_id
      order by tanimoto desc limit 1000
    ), contrib_projects as ( -- Pega projetos apoiados por esses X usuarios
      select u.user1_id, u.user2_id, u.tanimoto as users_tanimoto, ru2.name, unnest(ru2.contributions) project_id, u.user1_contribs
      from sim_users u
      join public.recommend_users ru2 on ru2.user_id=u.user2_id
    ), balanced_projects as (--balanceia tanimoto com a média de tanimotos relativos aos projetos apoiados
      select u.user1_id, u.user2_id, u.name, u.project_id, (u.users_tanimoto + avg(coalesce(pr.tanimoto,0)))/2 as tanimoto
      from contrib_projects u
      join projects p on p.id=u.project_id and p.state='online' and p.expires_at>now()+'12 hours'::interval -- filtra só os que estão online
      left join public.recommend_tanimoto_projects pr on pr.project1_id=project_id and pr.project2_id=ANY(u.user1_contribs)
      group by u.user1_id, u.user2_id, u.name, u.project_id, u.users_tanimoto
      order by tanimoto desc
    )
    select p.*
    from balanced_projects u
    join "1".projects p on p.project_id=u.project_id and p.state='online' and (p.expires_at is null or p.expires_at > current_timestamp+'1 day'::interval)
    where not exists (select true from "1".user_contributions c where c.user_id=user_id and c.state=ANY(confirmed_states()) and c.project_id=p.project_id limit 1)--here we will get updated value, not from materialized view
    order by u.tanimoto desc
    limit 10;
$BODY$
  LANGUAGE sql STABLE;

GRANT EXECUTE ON FUNCTION "1".recommend_projects2user(user_id integer) TO anonymous;
GRANT EXECUTE ON FUNCTION "1".recommend_projects2user(user_id integer) TO web_user;
GRANT EXECUTE ON FUNCTION "1".recommend_projects2user(user_id integer) TO admin;
GRANT SELECT ON public.recommend_users TO anonymous, web_user, admin;
GRANT SELECT ON public.recommend_tanimoto_users TO anonymous, web_user, admin;
GRANT SELECT ON public.recommend_tanimoto_projects TO anonymous, web_user, admin;
    }
  end

  def down
    execute %Q{
      DROP FUNCTION "1".recommend_projects2user(integer);
    }
  end
end
