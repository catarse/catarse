class AddActiveSavedAndInReminderProjectsInProjectsView < ActiveRecord::Migration[6.1]
  def change
    execute <<-SQL
      DROP VIEW "1".projects CASCADE;

      CREATE OR REPLACE VIEW "1".projects
        AS SELECT p.id AS project_id,
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
        remaining_time_json(p.*) AS remaining_time,
        p.expires_at,
        COALESCE((pms.data ->> 'pledged'::text)::numeric, 0::numeric) AS pledged,
        COALESCE((pms.data ->> 'progress'::text)::numeric, 0::numeric) AS progress,
        s.acronym AS state_acronym,
        u.name AS owner_name,
        c.name AS city_name,
        p.full_text_index,
        is_current_and_online(p.expires_at, p.state::text) AS open_for_contributions,
        elapsed_time_json(p.*) AS elapsed_time,
        COALESCE(pss.score::numeric, 0::numeric) AS score,
        (EXISTS ( SELECT true AS bool
              FROM contributions c_1
                JOIN user_follows uf ON uf.follow_id = c_1.user_id
              WHERE is_confirmed(c_1.*) AND uf.user_id = current_user_id() AND c_1.project_id = p.id)) AS contributed_by_friends,
        p.user_id AS project_user_id,
        p.video_embed_url,
        p.updated_at,
        u.public_name AS owner_public_name,
        zone_timestamp(p.expires_at) AS zone_expires_at,
        p.common_id,
        p.content_rating >= 18 AS is_adult_content,
        p.content_rating,
        ( SELECT array_to_string(array_agg(COALESCE(integration.data ->> 'name'::text, integration.name::text)), ','::text) AS integration_name
              FROM project_integrations integration
              WHERE integration.project_id = p.id) AS integrations,
        COALESCE(category.name_pt, category.name_en::text) AS category_name,
        (EXISTS (SELECT true AS bool FROM project_reminders pr
          WHERE (pr.project_id = p.id AND (is_current_and_online(p.expires_at, (p.state)::text) OR
          ((SELECT true AS bool FROM project_integrations integration WHERE (integration.project_id = p.id
              and integration.name = 'COMING_SOON_LANDING_PAGE') and p.state = 'draft' group by p.id)))
          and ((p.id = pr.project_id) AND (pr.user_id = current_user_id()))))) AS active_saved_projects,
        current_user_already_in_reminder(p.*) AS in_reminder,
        COALESCE((pms.data ->> 'count_project_reminders'::text)::numeric, 0::numeric) AS count_project_reminders
      FROM projects p
        JOIN users u ON p.user_id = u.id
        LEFT JOIN project_score_storages pss ON pss.project_id = p.id
        LEFT JOIN project_metric_storages pms ON pms.project_id = p.id
        LEFT JOIN cities c ON c.id = p.city_id
        LEFT JOIN states s ON s.id = c.state_id
        JOIN LATERAL zone_timestamp(online_at(p.*)) od(od) ON true
        JOIN LATERAL state_order(p.*) so(so) ON true
        LEFT JOIN categories category ON category.id = p.category_id
      WHERE p.state::text <> 'deleted'::text;

      grant select on "1"."projects" to admin, anonymous, web_user;

      CREATE OR REPLACE FUNCTION public.near_me("1".projects)
      RETURNS boolean
      LANGUAGE sql
      STABLE
      AS $function$
        SELECT
          COALESCE($1.state_acronym, (SELECT u.address_state FROM users u WHERE u.id = $1.project_user_id)) = (SELECT u.address_state FROM users u WHERE u.id = current_user_id());
      $function$;

      CREATE OR REPLACE FUNCTION public.is_expired(project projects)
      RETURNS boolean
      LANGUAGE sql
      STABLE
      AS $function$
        select
        case when $1.mode = 'sub' then
          false
        else
          public.is_past($1.expires_at)
        end;
      $function$;

      CREATE OR REPLACE FUNCTION public.is_expired(project "1".projects)
      RETURNS boolean
      LANGUAGE sql
      STABLE
      AS $function$
        select
        case when $1.mode = 'sub' then
            false
        else
          public.is_past($1.expires_at)
        end;
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
            p.open_for_contributions DESC,
            p.score DESC NULLS LAST,
            p.state DESC,
            ts_rank(p.full_text_index, plainto_tsquery('portuguese', unaccent(query))) DESC,
            p.project_id DESC;
      $function$;
    SQL
  end
end
