class AddsProjectUserIdtoProjects < ActiveRecord::Migration
  def up
    execute <<-SQL
SET STATEMENT_TIMEOUT TO 0;
    CREATE OR REPLACE VIEW "1".projects AS
    SELECT p.id AS project_id,
    p.category_id,
    p.name AS project_name,
    p.headline,
    p.permalink,
    p.mode,
    p.state::text,
    so.so AS state_order,
    od.od AS online_date,
    p.recommended,
    thumbnail_image(p.*, 'large'::text) AS project_img,
    remaining_time_json(p.*) AS remaining_time,
    p.expires_at,
    COALESCE(( SELECT
                CASE
                    WHEN p.state::text = 'failed'::text THEN pt.pledged
                    ELSE pt.paid_pledged
                END AS paid_pledged
           FROM "1".project_totals pt
          WHERE pt.project_id = p.id), 0::numeric) AS pledged,
    COALESCE(( SELECT pt.progress
           FROM "1".project_totals pt
          WHERE pt.project_id = p.id), 0::numeric) AS progress,
    s.acronym AS state_acronym,
    u.name AS owner_name,
    c.name AS city_name,
    p.full_text_index,
    is_current_and_online(p.expires_at, p.state::text) AS open_for_contributions,
    p.user_id AS project_user_id
   FROM projects p
     JOIN users u ON p.user_id = u.id
     JOIN cities c ON c.id = p.city_id
     JOIN states s ON s.id = c.state_id
     JOIN LATERAL zone_timestamp(online_at(p.*)) od(od) ON true
     JOIN LATERAL state_order(p.*) so(so) ON true;

    grant select on "1".projects to admin;
    grant select on "1".projects to web_user;
    grant select on "1".projects to anonymous;

    SQL
  end

  def down
    execute <<-SQL

DROP FUNCTION near_me("1".projects);
DROP FUNCTION "1".project_search(query text);
DROP FUNCTION public.is_expired(project "1".projects);
DROP FUNCTION public.score(pr "1".projects);
DROP VIEW "1".projects;

SET STATEMENT_TIMEOUT TO 0;
    CREATE OR REPLACE VIEW "1".projects AS
    SELECT p.id AS project_id,
    p.category_id,
    p.name AS project_name,
    p.headline,
    p.permalink,
    p.mode,
    p.state::text,
    so.so AS state_order,
    od.od AS online_date,
    p.recommended,
    thumbnail_image(p.*, 'large'::text) AS project_img,
    remaining_time_json(p.*) AS remaining_time,
    p.expires_at,
    COALESCE(( SELECT
                CASE
                    WHEN p.state::text = 'failed'::text THEN pt.pledged
                    ELSE pt.paid_pledged
                END AS paid_pledged
           FROM "1".project_totals pt
          WHERE pt.project_id = p.id), 0::numeric) AS pledged,
    COALESCE(( SELECT pt.progress
           FROM "1".project_totals pt
          WHERE pt.project_id = p.id), 0::numeric) AS progress,
    s.acronym AS state_acronym,
    u.name AS owner_name,
    c.name AS city_name,
    p.full_text_index,
    is_current_and_online(p.expires_at, p.state::text) AS open_for_contributions
   FROM projects p
     JOIN users u ON p.user_id = u.id
     JOIN cities c ON c.id = p.city_id
     JOIN states s ON s.id = c.state_id
     JOIN LATERAL zone_timestamp(online_at(p.*)) od(od) ON true
     JOIN LATERAL state_order(p.*) so(so) ON true;

    grant select on "1".projects to admin;
    grant select on "1".projects to web_user;
    grant select on "1".projects to anonymous;

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

       CREATE OR REPLACE FUNCTION public.score(pr "1".projects) RETURNS numeric
           STABLE LANGUAGE sql
           AS $$
               SELECT score FROM "1".project_scores WHERE project_id = pr.project_id
           $$;




    SQL
  end
end
