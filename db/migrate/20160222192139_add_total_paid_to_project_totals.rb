class AddTotalPaidToProjectTotals < ActiveRecord::Migration
    def up
    execute <<-SQL
set statement_timeout to 0;

DROP FUNCTION near_me("1".projects);
DROP FUNCTION "1".project_search(query text);
DROP FUNCTION public.is_expired(project "1".projects);
DROP VIEW "1".projects;

SELECT deps_save_and_drop_dependencies('1', 'project_totals');
DROP VIEW "1".project_totals;
CREATE OR REPLACE VIEW "1".project_totals AS
 SELECT c.project_id,
    sum(p.value) AS pledged,
    sum(p.value)
        FILTER (WHERE p.state = 'paid') AS paid_pledged,
    ((sum(p.value) / projects.goal) * (100)::numeric) AS progress,
    sum(p.gateway_fee) AS total_payment_service_fee,
    sum(p.gateway_fee)
        FILTER (WHERE p.state = 'paid') AS paid_total_payment_service_fee,
    count(DISTINCT c.id) AS total_contributions,
    count(DISTINCT c.user_id) AS total_contributors
   FROM ((contributions c
     JOIN projects ON ((c.project_id = projects.id)))
     JOIN payments p ON ((p.contribution_id = c.id)))
  WHERE (p.state = ANY (confirmed_states()))
  GROUP BY c.project_id, projects.id;
SELECT deps_restore_dependencies('1', 'project_totals');


SELECT deps_save_and_drop_dependencies('1', 'projects');
CREATE OR REPLACE VIEW "1".projects AS 
 SELECT p.id AS project_id,
    p.category_id,
    p.name AS project_name,
    p.headline,
    p.permalink,
    mode(p.*) AS mode,
    COALESCE(fp.state, (p.state)::text) AS state,
    so.so AS state_order,
    od.od AS online_date,
    p.recommended,
    thumbnail_image(p.*, 'large'::text) AS project_img,
    remaining_time_json(p.*) AS remaining_time,
    p.expires_at,
    COALESCE(( SELECT pt.pledged
           FROM "1".project_totals pt
          WHERE (pt.project_id = p.id)), (0)::numeric) AS pledged,
    COALESCE(( SELECT pt.progress
           FROM "1".project_totals pt
          WHERE (pt.project_id = p.id)), (0)::numeric) AS progress,
    s.acronym AS state_acronym,
    u.name AS owner_name,
    c.name AS city_name,
    p.full_text_index,
    is_current_and_online(p.expires_at, COALESCE(fp.state, (p.state)::text)) AS open_for_contributions
   FROM ((((((projects p
     JOIN users u ON ((p.user_id = u.id)))
     JOIN cities c ON ((c.id = p.city_id)))
     JOIN states s ON ((s.id = c.state_id)))
     JOIN LATERAL zone_timestamp(online_at(p.*)) od(od) ON (true))
     JOIN LATERAL state_order(p.*) so(so) ON (true))
     LEFT JOIN flexible_projects fp ON ((fp.project_id = p.id)));
SELECT deps_restore_dependencies('1', 'projects');

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


CREATE FUNCTION "1".project_search(query text) RETURNS SETOF "1".projects
    LANGUAGE sql STABLE
    AS $$
        SELECT
            p.*
        FROM
            "1".projects p
        WHERE
            (
                p.full_text_index @@ plainto_tsquery('portuguese', unaccent(query))
                OR
                p.project_name % query
            )
            AND p.state_order >= 'published'
        ORDER BY
            p.open_for_contributions DESC,
            p.state_order,
            ts_rank(p.full_text_index, plainto_tsquery('portuguese', unaccent(query))) DESC,
            p.project_id DESC;
     $$;
    SQL
  end

  def down
    execute <<-SQL
set statement_timeout to 0;

DROP FUNCTION near_me("1".projects);
DROP FUNCTION "1".project_search(query text);
DROP FUNCTION public.is_expired(project "1".projects);
DROP VIEW "1".projects;

SELECT deps_save_and_drop_dependencies('1', 'project_totals');
DROP VIEW "1".project_totals;
CREATE OR REPLACE VIEW "1".project_totals AS
 SELECT c.project_id,
    sum(p.value) AS pledged,
    ((sum(p.value) / projects.goal) * (100)::numeric) AS progress,
    sum(p.gateway_fee) AS total_payment_service_fee,
    count(DISTINCT c.id) AS total_contributions,
    count(DISTINCT c.user_id) AS total_contributors
   FROM ((contributions c
     JOIN projects ON ((c.project_id = projects.id)))
     JOIN payments p ON ((p.contribution_id = c.id)))
  WHERE (p.state = ANY (confirmed_states()))
  GROUP BY c.project_id, projects.id;
SELECT deps_restore_dependencies('1', 'project_totals');

SELECT deps_save_and_drop_dependencies('1', 'projects');
CREATE OR REPLACE VIEW "1".projects AS 
 SELECT p.id AS project_id,
    p.category_id,
    p.name AS project_name,
    p.headline,
    p.permalink,
    mode(p.*) AS mode,
    COALESCE(fp.state, (p.state)::text) AS state,
    so.so AS state_order,
    od.od AS online_date,
    p.recommended,
    thumbnail_image(p.*, 'large'::text) AS project_img,
    remaining_time_json(p.*) AS remaining_time,
    p.expires_at,
    COALESCE(( SELECT pt.pledged
           FROM "1".project_totals pt
          WHERE (pt.project_id = p.id)), (0)::numeric) AS pledged,
    COALESCE(( SELECT pt.progress
           FROM "1".project_totals pt
          WHERE (pt.project_id = p.id)), (0)::numeric) AS progress,
    s.acronym AS state_acronym,
    u.name AS owner_name,
    c.name AS city_name,
    p.full_text_index,
    is_current_and_online(p.expires_at, COALESCE(fp.state, (p.state)::text)) AS open_for_contributions
   FROM ((((((projects p
     JOIN users u ON ((p.user_id = u.id)))
     JOIN cities c ON ((c.id = p.city_id)))
     JOIN states s ON ((s.id = c.state_id)))
     JOIN LATERAL zone_timestamp(online_at(p.*)) od(od) ON (true))
     JOIN LATERAL state_order(p.*) so(so) ON (true))
     LEFT JOIN flexible_projects fp ON ((fp.project_id = p.id)));
SELECT deps_restore_dependencies('1', 'projects');

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


CREATE FUNCTION "1".project_search(query text) RETURNS SETOF "1".projects
    LANGUAGE sql STABLE
    AS $$
        SELECT
            p.*
        FROM
            "1".projects p
        WHERE
            (
                p.full_text_index @@ plainto_tsquery('portuguese', unaccent(query))
                OR
                p.project_name % query
            )
            AND p.state_order >= 'published'
        ORDER BY
            p.open_for_contributions DESC,
            p.state_order,
            ts_rank(p.full_text_index, plainto_tsquery('portuguese', unaccent(query))) DESC,
            p.project_id DESC;
     $$;

    SQL
  end
end
