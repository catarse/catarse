class AddTotalContributorsToProjectTotals < ActiveRecord::Migration
  def up
    execute <<-SQL
SET statement_timeout TO 0;
    SQL

    execute <<-SQL
DROP FUNCTION near_me("1".projects);
DROP FUNCTION listing_order(project "1".projects);
DROP FUNCTION "1".project_search(query text);
DROP VIEW "1".projects;

SELECT deps_save_and_drop_dependencies('1', 'project_totals');
DROP VIEW "1".project_totals;
CREATE VIEW "1".project_totals AS
SELECT c.project_id,
  sum(p.value) AS pledged,
  sum(p.value) / projects.goal * 100::numeric AS progress,
  sum(p.gateway_fee) AS total_payment_service_fee,
  count(DISTINCT c.id) AS total_contributions,
  count(DISTINCT c.user_id) AS total_contributors
FROM
  contributions c
  JOIN projects ON c.project_id = projects.id
  JOIN payments p ON p.contribution_id = c.id
WHERE p.state::text = ANY (confirmed_states())
GROUP BY c.project_id, projects.id;
SELECT deps_restore_dependencies('1', 'project_totals');

SELECT deps_save_and_drop_dependencies('1', 'projects');
CREATE VIEW "1".projects AS
 SELECT p.id AS project_id,
    p.name AS project_name,
    p.headline,
    p.permalink,
    public.mode(p.*) AS mode,
    COALESCE(fp.state, (p.state)::text) AS state,
    public.state_order(p.*) AS state_order,
    p.online_date,
    p.recommended,
    public.thumbnail_image(p.*, 'large'::text) AS project_img,
    public.remaining_time_json(p.*) AS remaining_time,
    p.expires_at,
    COALESCE(( SELECT pt.pledged
           FROM "1".project_totals pt
          WHERE (pt.project_id = p.id)), (0)::numeric) AS pledged,
    COALESCE(( SELECT pt.progress
           FROM "1".project_totals pt
          WHERE (pt.project_id = p.id)), (0)::numeric) AS progress,
    COALESCE(s.acronym, (pa.address_state)::character varying(255)) AS state_acronym,
    u.name AS owner_name,
    COALESCE(c.name, pa.address_city) AS city_name
   FROM (((((public.projects p
     JOIN public.users u ON ((p.user_id = u.id)))
     LEFT JOIN public.flexible_projects fp ON ((fp.project_id = p.id)))
     LEFT JOIN public.project_accounts pa ON ((pa.project_id = p.id)))
     LEFT JOIN public.cities c ON ((c.id = p.city_id)))
     LEFT JOIN public.states s ON ((s.id = c.state_id)));
SELECT deps_restore_dependencies('1', 'projects');

grant select on "1".projects to admin;
grant select on "1".projects to web_user;
grant select on "1".projects to anonymous;

CREATE FUNCTION near_me("1".projects) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
          SELECT
      COALESCE($1.state_acronym, (SELECT pa.address_state FROM project_accounts pa WHERE pa.project_id = $1.project_id)) = (SELECT u.address_state FROM users u WHERE u.id = nullif(current_setting('user_vars.user_id'), '')::int)
        $_$;

CREATE FUNCTION listing_order(project "1".projects) RETURNS integer
    LANGUAGE sql STABLE
    AS $$
    SELECT
        CASE project.state
            WHEN 'online' THEN 1
            WHEN 'waiting_funds' THEN 2
            WHEN 'successful' THEN 3
            WHEN 'failed' THEN 4
        END;
$$;

CREATE FUNCTION "1".project_search(query text) RETURNS SETOF "1".projects
    LANGUAGE sql STABLE
    AS $$
SELECT
    p.*
FROM
    "1".projects p
    JOIN public.projects pr ON pr.id = p.project_id
WHERE
    (
        pr.full_text_index @@ to_tsquery('portuguese', unaccent(query))
        OR
        pr.name % query
    )
    AND pr.state NOT IN ('draft','rejected','deleted','in_analysis','approved')
ORDER BY
    p.listing_order,
    ts_rank(pr.full_text_index, to_tsquery('portuguese', unaccent(query))) DESC,
    pr.id DESC;
$$;

SQL
  end

  def down
    execute <<-SQL
SET statement_timeout TO 0;
    SQL

    execute <<-SQL
DROP FUNCTION near_me("1".projects);
DROP FUNCTION listing_order(project "1".projects);
DROP FUNCTION "1".project_search(query text);

DROP VIEW "1".projects;

SELECT deps_save_and_drop_dependencies('1', 'project_totals');
DROP VIEW "1".project_totals;
CREATE VIEW "1".project_totals AS
SELECT c.project_id,
  sum(p.value) AS pledged,
  sum(p.value) / projects.goal * 100::numeric AS progress,
  sum(p.gateway_fee) AS total_payment_service_fee,
  count(DISTINCT c.id) AS total_contributions
FROM
  contributions c
  JOIN projects ON c.project_id = projects.id
  JOIN payments p ON p.contribution_id = c.id
WHERE p.state::text = ANY (confirmed_states())
GROUP BY c.project_id, projects.id;
SELECT deps_restore_dependencies('1', 'project_totals');

SELECT deps_save_and_drop_dependencies('1', 'projects');
CREATE VIEW "1".projects AS
 SELECT p.id AS project_id,
    p.name AS project_name,
    p.headline,
    p.permalink,
    public.mode(p.*) AS mode,
    COALESCE(fp.state, (p.state)::text) AS state,
    public.state_order(p.*) AS state_order,
    p.online_date,
    p.recommended,
    public.thumbnail_image(p.*, 'large'::text) AS project_img,
    public.remaining_time_json(p.*) AS remaining_time,
    p.expires_at,
    COALESCE(( SELECT pt.pledged
           FROM "1".project_totals pt
          WHERE (pt.project_id = p.id)), (0)::numeric) AS pledged,
    COALESCE(( SELECT pt.progress
           FROM "1".project_totals pt
          WHERE (pt.project_id = p.id)), (0)::numeric) AS progress,
    COALESCE(s.acronym, (pa.address_state)::character varying(255)) AS state_acronym,
    u.name AS owner_name,
    COALESCE(c.name, pa.address_city) AS city_name
   FROM (((((public.projects p
     JOIN public.users u ON ((p.user_id = u.id)))
     LEFT JOIN public.flexible_projects fp ON ((fp.project_id = p.id)))
     LEFT JOIN public.project_accounts pa ON ((pa.project_id = p.id)))
     LEFT JOIN public.cities c ON ((c.id = p.city_id)))
     LEFT JOIN public.states s ON ((s.id = c.state_id)));
SELECT deps_restore_dependencies('1', 'projects');

grant select on "1".projects to admin;
grant select on "1".projects to web_user;
grant select on "1".projects to anonymous;

CREATE FUNCTION near_me("1".projects) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
          SELECT
      COALESCE($1.state_acronym, (SELECT pa.address_state FROM project_accounts pa WHERE pa.project_id = $1.project_id)) = (SELECT u.address_state FROM users u WHERE u.id = nullif(current_setting('user_vars.user_id'), '')::int)
        $_$;

CREATE FUNCTION listing_order(project "1".projects) RETURNS integer
    LANGUAGE sql STABLE
    AS $$
    SELECT
        CASE project.state
            WHEN 'online' THEN 1
            WHEN 'waiting_funds' THEN 2
            WHEN 'successful' THEN 3
            WHEN 'failed' THEN 4
        END;
$$;

CREATE FUNCTION "1".project_search(query text) RETURNS SETOF "1".projects
    LANGUAGE sql STABLE
    AS $$
SELECT
    p.*
FROM
    "1".projects p
    JOIN public.projects pr ON pr.id = p.project_id
WHERE
    (
        pr.full_text_index @@ to_tsquery('portuguese', unaccent(query))
        OR
        pr.name % query
    )
    AND pr.state NOT IN ('draft','rejected','deleted','in_analysis','approved')
ORDER BY
    p.listing_order,
    ts_rank(pr.full_text_index, to_tsquery('portuguese', unaccent(query))) DESC,
    pr.id DESC;
$$;

SQL
  end
end
