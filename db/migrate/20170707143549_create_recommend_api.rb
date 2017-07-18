class CreateRecommendApi < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE VIEW "1".recommend_projects2user AS
  select us.id as user_id, p.*
  from users us
  join lateral (
    with ucprojects as (
      select distinct c.project_id
      from public.contributions c
      join payments p on p.contribution_id=c.id and p.state=ANY(confirmed_states())
      where c.user_id=us.id
    ), sim_users as ( -- Pega X usuarios mais proximos a você
      select u.user1_id, u.user2_id, u.tanimoto
      from public.recommend_tanimoto_users u
      where u.user1_id=us.id
        and u.user2_id not in (select id from users where banned_at is not null or deactivated_at is not null) -- filtra banidos
      order by tanimoto desc limit 1000  --Aqui, se nao precisar ser realtime, podemos deixar sem limite.
    ), contrib_projects as ( -- Pega projetos apoiados por esses X usuarios
      select distinct c.project_id, u.user1_id, u.user2_id, u.tanimoto as users_tanimoto
      from sim_users u
      join contributions c on c.user_id=u.user2_id and c.project_id not in (select project_id from public.recommend_projects_blacklist union select project_id from ucprojects)
      join payments p on p.contribution_id=c.id and p.state=ANY(confirmed_states())
    ), balanced_projects as (--balanceia tanimoto com a média de tanimotos relativos aos projetos apoiados
      select u.project_id, u.user1_id, u.user2_id,
          (max(u.users_tanimoto) + avg(coalesce(pr.tanimoto,0)))/2 as tanimoto
      from contrib_projects u
      join projects p on p.id=u.project_id and p.state='online' and p.expires_at>current_timestamp+'1 day'::interval -- filtra só os que estão online
      left join public.recommend_tanimoto_projects pr on pr.project1_id=u.project_id
       and pr.project2_id in (select project_id from ucprojects)
      group by u.project_id, u.user1_id, u.user2_id
    )

    select u.project_id, avg(tanimoto) as tanimoto
    from balanced_projects u
    group by u.project_id
    order by avg(tanimoto) desc limit 10
  ) t on true
  join "1".projects p using(project_id)
  where us.banned_at IS NULL AND us.deactivated_at IS NULL
  order by t.tanimoto desc;

GRANT SELECT ON TABLE "1".recommend_projects2user TO admin;
GRANT SELECT ON TABLE "1".recommend_projects2user TO web_user;
    }
  end

  def down
    execute %Q{
      DROP FUNCTION "1".recommend_projects2user(integer);
    }
  end
end
