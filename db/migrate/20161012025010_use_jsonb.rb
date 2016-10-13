class UseJsonb < ActiveRecord::Migration
  def change
    execute <<-SQL
SET statement_timeout TO 0;
    SQL

    execute <<-SQL
CREATE OR REPLACE FUNCTION public.interval_to_jsonb(interval) RETURNS jsonb
    LANGUAGE sql IMMUTABLE SECURITY DEFINER
    AS $_$
            select (
              case
              when $1 <= '0 seconds'::interval then
                jsonb_build_object('total', 0, 'unit', 'seconds')
              else
                case
                when $1 >= '1 day'::interval then
                  jsonb_build_object('total', extract(day from $1), 'unit', 'days')
                when $1 >= '1 hour'::interval and $1 < '24 hours'::interval then
                  jsonb_build_object('total', extract(hour from $1), 'unit', 'hours')
                when $1 >= '1 minute'::interval and $1 < '60 minutes'::interval then
                  jsonb_build_object('total', extract(minutes from $1), 'unit', 'minutes')
                when $1 < '60 seconds'::interval then
                  jsonb_build_object('total', extract(seconds from $1), 'unit', 'seconds')
                 else jsonb_build_object('total', 0, 'unit', 'seconds') end
              end
            )
        $_$;

CREATE OR REPLACE FUNCTION public.remaining_time_jsonb(projects) RETURNS jsonb
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
            select public.interval_to_jsonb($1.remaining_time_interval)
        $_$;

CREATE OR REPLACE FUNCTION public.elapsed_time_jsonb(projects) RETURNS jsonb
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
            select public.interval_to_jsonb(least(now(), $1.expires_at) - $1.online_at)
        $_$;

        drop FUNCTION if exists "1".project_search(query text);
        drop FUNCTION if exists public.is_expired(project "1".projects);
        drop FUNCTION if exists public.near_me("1".projects);
        drop view "1".projects;
        


        CREATE OR REPLACE VIEW "1".projects AS
        SELECT p.id AS project_id,
        p.category_id,
        p.name AS project_name,
        p.headline,
        p.permalink,
        p.mode,
        p.state::text AS state,
        so.so AS state_order,
        od.od AS online_date,
        p.recommended,
        thumbnail_image(p.*, 'large'::text) AS project_img,
        remaining_time_jsonb(p.*) AS remaining_time,
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
                            elapsed_time_jsonb(p.*) AS elapsed_time,
                            score(p.*) AS score,
                            (EXISTS ( SELECT true AS bool
                                     FROM contributions c_1
                                     JOIN user_follows uf ON uf.follow_id = c_1.user_id
                                     WHERE is_confirmed(c_1.*) AND uf.user_id = current_user_id() AND c_1.project_id = p.id)) AS contributedbyfriends,
                                     (EXISTS ( SELECT true AS bool
                                              FROM contributions c_1
                                              JOIN user_follows uf ON uf.follow_id = c_1.user_id
                                              WHERE is_confirmed(c_1.*) AND uf.user_id = current_user_id() AND c_1.project_id = p.id)) AS contributed_by_friends,
                                              p.user_id AS project_user_id,
                                              p.video_embed_url
                                              FROM projects p
                                              JOIN users u ON p.user_id = u.id
                                              JOIN cities c ON c.id = p.city_id
                                              JOIN states s ON s.id = c.state_id
                                              JOIN LATERAL zone_timestamp(online_at(p.*)) od(od) ON true
                                              JOIN LATERAL state_order(p.*) so(so) ON true;


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
                p.full_text_index @@ plainto_tsquery('portuguese', unaccent(query))
                OR
                p.project_name % query
            )
            AND p.state_order >= 'published'
        ORDER BY
            p.score DESC NULLS LAST,
            p.open_for_contributions DESC,
            p.state_order,
            ts_rank(p.full_text_index, plainto_tsquery('portuguese', unaccent(query))) DESC,
            p.project_id DESC;
     $function$
        

     SQL
     end
end
