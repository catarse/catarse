class AddsFtiToProjectsEndpoint < ActiveRecord::Migration
  def up
    execute <<-SQL
DROP VIEW "1".projects CASCADE;
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
    COALESCE(c.name, pa.address_city) AS city_name,
    p.full_text_index
   FROM (((((public.projects p
     JOIN public.users u ON ((p.user_id = u.id)))
     LEFT JOIN public.flexible_projects fp ON ((fp.project_id = p.id)))
     LEFT JOIN public.project_accounts pa ON ((pa.project_id = p.id)))
     LEFT JOIN public.cities c ON ((c.id = p.city_id)))
     LEFT JOIN public.states s ON ((s.id = c.state_id)));

GRANT SELECT ON TABLE "1".projects TO anonymous;
GRANT SELECT ON TABLE "1".projects TO web_user;
GRANT SELECT ON TABLE "1".projects TO admin;


CREATE OR REPLACE FUNCTION public.is_expired(expires_at timestamp)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
SELECT COALESCE(current_timestamp > expires_at, false);
$function$;

CREATE OR REPLACE FUNCTION public.is_expired(project public.projects)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
SELECT public.is_expired($1.expires_at);
$function$;

CREATE OR REPLACE FUNCTION public.is_expired(project "1".projects)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
SELECT public.is_expired($1.expires_at);
$function$;

CREATE OR REPLACE FUNCTION public.open_for_contributions(expires_at timestamp, state text)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
SELECT (not public.is_expired(expires_at) AND state = 'online');
$function$;

CREATE OR REPLACE FUNCTION public.open_for_contributions(projects)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
SELECT public.open_for_contributions($1.expires_at, COALESCE(fp.state, $1.state))
FROM projects p
LEFT JOIN flexible_projects fp on fp.project_id = p.id
WHERE p.id = $1.id;
$function$;


CREATE OR REPLACE FUNCTION public.state_order(project_id int)
 RETURNS project_state_order
 LANGUAGE sql
 STABLE
AS $function$
SELECT
    CASE p.mode
    WHEN 'flex' THEN
        (
        SELECT state_order
        FROM
        flexible_project_states ps
        WHERE
        ps.state = fp.state
        )
    ELSE
        (
        SELECT state_order
        FROM
        project_states ps
        WHERE
        ps.state = p.state
        )
    END
FROM projects p
LEFT JOIN flexible_projects fp on fp.project_id = p.id
WHERE p.id = $1;
$function$;

CREATE OR REPLACE FUNCTION public.state_order(project public.projects)
 RETURNS project_state_order
 LANGUAGE sql
 STABLE
AS $function$
SELECT public.state_order($1.id);
$function$;

CREATE OR REPLACE FUNCTION public.near_me("1".projects)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
          SELECT
      COALESCE($1.state_acronym, (SELECT pa.address_state FROM project_accounts pa WHERE pa.project_id = $1.project_id)) = (SELECT u.address_state FROM users u WHERE u.id = current_user_id());
        $function$;

CREATE OR REPLACE FUNCTION "1".project_search(query text)
 RETURNS SETOF "1".projects
 LANGUAGE sql
 STABLE
AS $function$
SELECT
    p.*
FROM
    "1".projects p
WHERE
    (
        p.full_text_index @@ to_tsquery('portuguese', unaccent(query))
        OR
        p.project_name % query
    )
    AND p.state_order >= 'published'
ORDER BY
    public.open_for_contributions(p.expires_at, p.state) DESC,
    p.state_order,
    ts_rank(p.full_text_index, to_tsquery('portuguese', unaccent(query))) DESC,
    p.project_id DESC;
$function$;
    SQL
  end

  def down
    execute <<-SQL
DROP VIEW "1".projects CASCADE;

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

GRANT SELECT ON TABLE "1".projects TO anonymous;
GRANT SELECT ON TABLE "1".projects TO web_user;
GRANT SELECT ON TABLE "1".projects TO admin;

CREATE OR REPLACE FUNCTION "1".project_search(query text)
 RETURNS SETOF "1".projects
 LANGUAGE sql
 STABLE
AS $function$
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
    AND pr.state_order >= 'published'
ORDER BY
    p.listing_order,
    ts_rank(pr.full_text_index, to_tsquery('portuguese', unaccent(query))) DESC,
    pr.id DESC;
$function$;

CREATE OR REPLACE FUNCTION public.listing_order(project "1".projects)
 RETURNS integer
 LANGUAGE sql
 STABLE
AS $function$
    SELECT
        CASE project.state
            WHEN 'online' THEN 1
            WHEN 'waiting_funds' THEN 2
            WHEN 'successful' THEN 3
            WHEN 'failed' THEN 4
        END;
$function$;

CREATE OR REPLACE FUNCTION public.near_me("1".projects)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
          SELECT
      COALESCE($1.state_acronym, (SELECT pa.address_state FROM project_accounts pa WHERE pa.project_id = $1.project_id)) = (SELECT u.address_state FROM users u WHERE u.id = current_user_id())
        $function$;
    SQL
  end
end
