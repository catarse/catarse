class CreateRecommendViews < ActiveRecord::Migration
  def up
    execute %Q{
CREATE TABLE public.recommend_projects_blacklist (
   project_id integer not null, 
   reason text, 
   CONSTRAINT recommend_projects_blacklist_pkey PRIMARY KEY (project_id),
   CONSTRAINT recommend_projects_blacklist_project_referencia FOREIGN KEY (project_id)
      REFERENCES public.projects (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

-- Materialized View: public.recommend_projects
CREATE MATERIALIZED VIEW public.recommend_projects AS 
-- some projects will be used only for name similarity
SELECT p.id AS project_id,
       p.name,p.state,p.city_id,p.category_id,
       (select NULLIF(array_agg(DISTINCT c.user_id), '{NULL}'::integer[]) from contributions c join payments pa on c.project_id = p.id AND pa.contribution_id=c.id AND pa.state=ANY(confirmed_states())) AS contributors,
       (select NULLIF(array_agg(DISTINCT t_1.id), '{NULL}'::integer[]) from taggings tg join public_tags t_1 ON tg.project_id = p.id and t_1.id = tg.public_tag_id) AS tags,
       (select NULLIF(array_agg(DISTINCT r.user_id), '{NULL}'::integer[]) from project_reminders r where r.project_id = p.id) AS reminders,
       (select NULLIF(array_agg(DISTINCT m.user_id), '{NULL}'::integer[]) from moments_project_pageviews_inferuser m where m.project_id=p.id) AS visitors,
       max(tro.created_at) as online_at,
       coalesce(coalesce(min(trw.created_at), min(trf.created_at)), p.expires_at) as closed_at,
       min(trf.created_at) as finished_at
     FROM projects p
     JOIN project_transitions tro on tro.project_id=p.id and tro.to_state='online' and tro.created_at>p.created_at
     LEFT JOIN project_transitions trw on trw.project_id=p.id and trw.to_state='waiting_funds' and trw.created_at>tro.created_at
     LEFT JOIN project_transitions trf on trf.project_id=p.id and trf.to_state in ('successful','failed') and trf.created_at>tro.created_at
     WHERE p.state::text = ANY (ARRAY['online', 'waiting_funds', 'successful', 'failed'])
     GROUP BY p.id
WITH NO DATA;
CREATE UNIQUE INDEX recommend_projects_idx
  ON public.recommend_projects
  USING btree (project_id);
CREATE INDEX recommend_projects_name_idx
  ON public.recommend_projects
  USING gist (name COLLATE pg_catalog."default" gist_trgm_ops);
CREATE INDEX reminders_projects_onlineat_idx
  ON public.recommend_projects
  USING btree (online_at);
CREATE INDEX reminders_projects_closedat_idx
  ON public.recommend_projects
  USING btree (closed_at);
CREATE INDEX reminders_projects_contribnnull_idx
  ON public.recommend_projects
  USING btree ((contributors IS NOT NULL));
CREATE INDEX reminders_projects_contribs_idx
  ON public.recommend_projects
  USING gin (contributors);
CREATE INDEX reminders_projects_remindnnull_idx
  ON public.recommend_projects
  USING btree ((reminders IS NOT NULL));
CREATE INDEX reminders_projects_reminds_idx
  ON public.recommend_projects
  USING gin (reminders);
CREATE INDEX reminders_projects_tagnnull_idx
  ON public.recommend_projects
  USING btree ((tags IS NOT NULL));
CREATE INDEX reminders_projects_tags_idx
  ON public.recommend_projects
  USING gin(tags);
CREATE INDEX reminders_projects_visitnnull_idx
  ON public.recommend_projects
  USING btree ((visitors IS NOT NULL));
CREATE INDEX reminders_projects_visits_idx
  ON public.recommend_projects
  USING gin(visitors);

-----------------------------------------------------------------------
-- Materialized View: public.recommend_tanimoto_projects
CREATE MATERIALIZED VIEW public.recommend_tanimoto_projects AS 
  SELECT t.* FROM (
SELECT p1.project_id AS project1_id,
      p2.project_id AS project2_id,
      p1.name AS project1_name,
      p2.name AS project2_name,
      p1.state AS project1_state,
      p2.state AS project2_state,
      p1.category_id AS project1_category_id,
      p2.category_id AS project2_category_id,
      p1.closed_at as project1_closed_at,
      p2.closed_at as project2_closed_at,
  round((
    CASE WHEN (p1.contributors && p2.contributors) THEN (
        array_length(ARRAY(SELECT unnest(p1.contributors) INTERSECT SELECT unnest(p2.contributors)), 1)
      / array_length(ARRAY(SELECT unnest(p1.contributors) UNION SELECT unnest(p2.contributors))    , 1)::numeric
    ) ELSE 0::numeric END +
    CASE WHEN (p1.reminders && p2.reminders) THEN (
        array_length(ARRAY(SELECT unnest(p1.reminders) INTERSECT SELECT unnest(p2.reminders)), 1)
      / array_length(ARRAY(SELECT unnest(p1.reminders) UNION SELECT unnest(p2.reminders))    , 1)::numeric
    ) ELSE 0::numeric END +
    CASE WHEN (p1.tags && p2.tags) THEN (
        array_length(ARRAY(SELECT unnest(p1.tags) INTERSECT SELECT unnest(p2.tags)), 1)
      / array_length(ARRAY(SELECT unnest(p1.tags) UNION SELECT unnest(p2.tags))    , 1)::numeric
    ) ELSE 0::numeric END +
    CASE WHEN (p1.visitors && p2.visitors) THEN (
        array_length(ARRAY(SELECT unnest(p1.visitors) INTERSECT SELECT unnest(p2.visitors)), 1)
      / array_length(ARRAY(SELECT unnest(p1.visitors) UNION SELECT unnest(p2.visitors))    , 1)::numeric
    ) ELSE 0::numeric END
  ) / 4, 4) AS tanimoto
  FROM public.recommend_projects p1
  JOIN public.recommend_projects p2 ON p1.project_id <> p2.project_id AND (--It makes no sense to recommend projects that are not online simultaneously
        (p2.online_at<p1.online_at AND (p2.closed_at is null or p2.closed_at>p1.online_at+'1 hour'::interval))--Or p2 started before, but closed later
     OR (p2.online_at>p1.online_at AND (p1.closed_at is null or p2.online_at<p1.closed_at-'1 hour'::interval))--Or p2 started after, but started before closing p1
  ) and p2.project_id not in (select project_id from public.recommend_projects_blacklist)--P2 can not recommend blacklisted projects!
  JOIN projects p2p on p2p.id=p2.project_id and p2.state='online'--Just confirm that the project is still online!
WHERE (p1.contributors && p2.contributors OR p1.reminders && p2.reminders OR p1.tags && p2.tags OR p1.visitors && p2.visitors)
  )t where tanimoto >=0.0001 --threshold
WITH NO DATA;
CREATE UNIQUE INDEX recommend_tanimoto_projects_idx
  ON public.recommend_tanimoto_projects
  USING btree (project1_id, project2_id);
CREATE INDEX recommend_tanimoto_projects_projid_tanimoto_idx
  ON public.recommend_tanimoto_projects
  USING btree (project1_id, tanimoto);
CREATE INDEX recommend_tanimoto_projects_tanimoto_idx
  ON public.recommend_tanimoto_projects
  USING btree (project1_id, project2_id, tanimoto);

------ USERS
-- Materialized View: public.recommend_users
CREATE MATERIALIZED VIEW public.recommend_users AS 
  SELECT * from (
    SELECT u.id AS user_id, u.name,
       (select NULLIF(array_agg(DISTINCT c.project_id), '{NULL}'::integer[])
          from contributions c
          join payments pa on pa.contribution_id=c.id and pa.state=ANY(confirmed_states())
        where c.user_id = u.id and c.created_at>=now()-'1 year'::interval
          and c.project_id not in (select project_id from recommend_projects_blacklist)) AS contributions,
       (select NULLIF(array_agg(DISTINCT r.project_id), '{NULL}'::integer[])
          from project_reminders r
        where r.user_id = u.id
          and r.project_id not in (select project_id from recommend_projects_blacklist)) AS reminders,
       (select NULLIF(array_agg(DISTINCT project_id), '{NULL}'::integer[])
          from moments_project_pageviews_inferuser m
        where m.user_id=u.id
          and m.project_id not in (select project_id from recommend_projects_blacklist)) AS visited
    FROM users u
    WHERE u.banned_at is null and u.deactivated_at is null and u.sign_in_count>0
    GROUP BY u.id
  )t where contributions is not null or reminders is not null or visited is not null
WITH NO DATA;
CREATE UNIQUE INDEX recommend_users_idx ON public.recommend_users USING btree (user_id);
CREATE INDEX reminders_users_contribnnull_idx ON public.recommend_users USING btree ((contributions IS NOT NULL));
CREATE INDEX reminders_users_contribs_idx ON public.recommend_users USING gin (contributions);
CREATE INDEX reminders_users_remindnnull_idx ON public.recommend_users USING btree ((reminders IS NOT NULL));
CREATE INDEX reminders_users_reminds_idx ON public.recommend_users USING gin (reminders);
CREATE INDEX reminders_users_visitnnull_idx ON public.recommend_users USING btree ((visited IS NOT NULL));
CREATE INDEX reminders_users_visits_idx ON public.recommend_users USING gin(visited);

-----------------------------------------------------------------------
-- Materialized View: public.recommend_tanimoto_user_contributors
CREATE MATERIALIZED VIEW public.recommend_tanimoto_user_contributions AS 
select * from (
 SELECT q1.user_id AS user1_id, q2.user_id AS user2_id,
    COALESCE(
      array_length(ARRAY(SELECT unnest(q1.contributions) AS unnest INTERSECT SELECT unnest(q2.contributions) AS unnest), 1)::numeric
      / array_length(ARRAY( SELECT unnest(q1.contributions) AS unnest UNION SELECT unnest(q2.contributions) AS unnest), 1)::numeric, 0::numeric
    ) AS tanimoto
  FROM public.recommend_users q1
  JOIN public.recommend_users q2 ON q1.contributions IS NOT NULL AND q2.contributions IS NOT NULL AND q1.contributions && q2.contributions
  --WHERE q1.user_id <> q2.user_id  --optimized for index, we filter after
) t where user1_id<>user2_id
WITH NO DATA;
CREATE UNIQUE INDEX recommend_tanimoto_user_contributions_idx
  ON public.recommend_tanimoto_user_contributions
  USING btree (user1_id, user2_id);
CREATE INDEX recommend_tanimoto_user_contributions_userid_tanimoto_idx
  ON public.recommend_tanimoto_user_contributions
  USING btree (user1_id, user2_id);
CREATE INDEX recommend_tanimoto_user_contributions_user1id_idx
  ON public.recommend_tanimoto_user_contributions
  USING btree (user1_id);
-----------------------------------------------------------------------
-- Materialized View: public.recommend_tanimoto_user_reminders
CREATE MATERIALIZED VIEW public.recommend_tanimoto_user_reminders AS 
 SELECT q1.user_id AS user1_id, q2.user_id AS user2_id,
    COALESCE(
      array_length(ARRAY(SELECT unnest(q1.reminders) AS unnest INTERSECT SELECT unnest(q2.reminders) AS unnest), 1)::numeric
      / array_length(ARRAY( SELECT unnest(q1.reminders) AS unnest UNION SELECT unnest(q2.reminders) AS unnest), 1)::numeric, 0::numeric
    ) AS tanimoto
  FROM public.recommend_users q1
  JOIN public.recommend_users q2 ON q1.reminders IS NOT NULL AND q2.reminders IS NOT NULL AND q1.reminders && q2.reminders
  WHERE q1.user_id <> q2.user_id
WITH NO DATA;
CREATE UNIQUE INDEX recommend_tanimoto_user_reminders_idx
  ON public.recommend_tanimoto_user_reminders
  USING btree (user1_id, user2_id);
CREATE INDEX recommend_tanimoto_user_reminders_userid_tanimoto_idx
  ON public.recommend_tanimoto_user_reminders
  USING btree (user1_id, tanimoto);
CREATE INDEX recommend_tanimoto_user_reminders_user1id_idx
  ON public.recommend_tanimoto_user_reminders
  USING btree (user1_id);

-----------------------------------------------------------------------
-- Materialized View: public.recommend_tanimoto_user_visited
CREATE MATERIALIZED VIEW public.recommend_tanimoto_user_visited AS 
 SELECT q1.user_id AS user1_id, q2.user_id AS user2_id,
    COALESCE(
      array_length(ARRAY(SELECT unnest(q1.visited) AS unnest INTERSECT SELECT unnest(q2.visited) AS unnest), 1)::numeric
      / array_length(ARRAY( SELECT unnest(q1.visited) AS unnest UNION SELECT unnest(q2.visited) AS unnest), 1)::numeric, 0::numeric
    ) AS tanimoto
  FROM public.recommend_users q1
  JOIN public.recommend_users q2 ON q1.visited IS NOT NULL AND q2.visited IS NOT NULL AND q1.visited && q2.visited
  WHERE q1.user_id <> q2.user_id
WITH NO DATA;
CREATE UNIQUE INDEX recommend_tanimoto_user_visited_idx
  ON public.recommend_tanimoto_user_visited
  USING btree (user1_id, user2_id);
CREATE INDEX recommend_tanimoto_user_visited_userid_tanimoto_idx
  ON public.recommend_tanimoto_user_visited
  USING btree (user1_id, tanimoto);
CREATE INDEX recommend_tanimoto_user_visited_user1id_idx
  ON public.recommend_tanimoto_user_visited
  USING btree (user1_id);

--------------------------------------------------------------------------------------
-- View: public.recommend_tanimoto_users
CREATE OR REPLACE VIEW public.recommend_tanimoto_users AS 
 SELECT u1.user_id AS user1_id, u2.user_id AS user2_id,
    round((COALESCE(c.tanimoto, 0::numeric) + COALESCE(r.tanimoto, 0::numeric) + COALESCE(r.tanimoto, 0::numeric))/3::numeric,4) AS tanimoto
   FROM public.recommend_users u1
   JOIN public.recommend_users u2 ON u2.user_id <> u1.user_id
   LEFT JOIN public.recommend_tanimoto_user_contributions c ON c.user1_id = u1.user_id AND c.user2_id = u2.user_id
   LEFT JOIN public.recommend_tanimoto_user_visited v ON v.user1_id = u1.user_id AND v.user2_id = u2.user_id
   LEFT JOIN public.recommend_tanimoto_user_reminders r ON r.user1_id = u1.user_id AND r.user2_id = u2.user_id
   WHERE (COALESCE(c.tanimoto, 0::numeric) + COALESCE(r.tanimoto, 0::numeric) + COALESCE(r.tanimoto, 0::numeric))/3::numeric > 0.0001 --threshold
 ORDER BY tanimoto DESC;

-- Should be used only pointing a user_id. A select for more than one user will be so long.
CREATE OR REPLACE VIEW public.recommend_projects2user AS
  select us.id as user_id, t.*
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
  where us.banned_at IS NULL AND us.deactivated_at IS NULL
  order by tanimoto desc;
    }
  end

  def down
    execute %Q{
      DROP VIEW public.recommend_projects2user;
      DROP VIEW public.recommend_tanimoto_users;
      DROP MATERIALIZED VIEW public.recommend_tanimoto_user_visited;
      DROP MATERIALIZED VIEW public.recommend_tanimoto_user_reminders;
      DROP MATERIALIZED VIEW public.recommend_tanimoto_user_contributions;
      DROP MATERIALIZED VIEW public.recommend_users;
      DROP MATERIALIZED VIEW public.recommend_tanimoto_projects;
      DROP MATERIALIZED VIEW public.recommend_projects;
      DROP TABLE public.recommend_projects_blacklist;
    }
  end
end
