class AddsCategoryIdToProjectsEndpoint < ActiveRecord::Migration
  def up
    execute <<-SQL
DROP VIEW "1".projects CASCADE;

CREATE VIEW "1".projects AS
 SELECT
    p.id,
    p.category_id,
    p.id AS project_id,
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

GRANT SELECT ON TABLE "1".projects TO anonymous, web_user, admin;

CREATE OR REPLACE FUNCTION public.near_me("1".projects)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
    SELECT
      COALESCE($1.state_acronym, (SELECT pa.address_state FROM project_accounts pa WHERE pa.project_id = $1.project_id)) = (SELECT u.address_state FROM users u WHERE u.id = current_user_id());
$function$;

CREATE OR REPLACE FUNCTION public.is_expired(project "1".projects)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
    SELECT public.is_past($1.expires_at);
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
    public.is_current_and_online(p.expires_at, p.state) DESC,
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
    COALESCE(c.name, pa.address_city) AS city_name,
    p.full_text_index
   FROM (((((public.projects p
     JOIN public.users u ON ((p.user_id = u.id)))
     LEFT JOIN public.flexible_projects fp ON ((fp.project_id = p.id)))
     LEFT JOIN public.project_accounts pa ON ((pa.project_id = p.id)))
     LEFT JOIN public.cities c ON ((c.id = p.city_id)))
     LEFT JOIN public.states s ON ((s.id = c.state_id)));

GRANT SELECT ON TABLE "1".projects TO anonymous, web_user, admin;

CREATE OR REPLACE FUNCTION public.near_me("1".projects)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
    SELECT
      COALESCE($1.state_acronym, (SELECT pa.address_state FROM project_accounts pa WHERE pa.project_id = $1.project_id)) = (SELECT u.address_state FROM users u WHERE u.id = current_user
$function$;

CREATE OR REPLACE FUNCTION public.is_expired(project "1".projects)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
    SELECT public.is_past($1.expires_at);
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
    public.is_current_and_online(p.expires_at, p.state) DESC,
    p.state_order,
    ts_rank(p.full_text_index, to_tsquery('portuguese', unaccent(query))) DESC,
    p.project_id DESC;
$function$;
    SQL
  end
end
