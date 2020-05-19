class ProjectsWithAllIntegrationsNames < ActiveRecord::Migration
  def change
    execute <<-SQL

    CREATE OR REPLACE VIEW "1"."projects" AS 
    SELECT p.id AS project_id,
        p.category_id,
        p.name AS project_name,
        p.headline,
        p.permalink,
        p.mode,
        (p.state)::text AS state,
        so.so AS state_order,
        od.od AS online_date,
        p.recommended,
        thumbnail_image(p.*, 'large'::text) AS project_img,
        remaining_time_json(p.*) AS remaining_time,
        p.expires_at,
        COALESCE(((pms.data ->> 'pledged'::text))::numeric, (0)::numeric) AS pledged,
        COALESCE(((pms.data ->> 'progress'::text))::numeric, (0)::numeric) AS progress,
        s.acronym AS state_acronym,
        u.name AS owner_name,
        c.name AS city_name,
        p.full_text_index,
        is_current_and_online(p.expires_at, (p.state)::text) AS open_for_contributions,
        elapsed_time_json(p.*) AS elapsed_time,
        COALESCE((pss.score)::numeric, (0)::numeric) AS score,
        (EXISTS ( SELECT true AS bool
               FROM (contributions c_1
                 JOIN user_follows uf ON ((uf.follow_id = c_1.user_id)))
              WHERE ((is_confirmed(c_1.*) AND (uf.user_id = current_user_id())) AND (c_1.project_id = p.id)))) AS contributed_by_friends,
        p.user_id AS project_user_id,
        p.video_embed_url,
        p.updated_at,
        u.public_name AS owner_public_name,
        zone_timestamp(p.expires_at) AS zone_expires_at,
        p.common_id,
        (p.content_rating >= 18) AS is_adult_content,
        p.content_rating,
        (
            EXISTS ( 
                SELECT true AS bool
                FROM project_reminders pr
                WHERE ((p.id = pr.project_id) AND (pr.user_id = current_user_id()))
            )
        ) AS saved_projects,
        COALESCE(category.name_pt, category.name_en) as category_name,
        (
            SELECT 
                array_to_string(array_agg(COALESCE(integration.data->>'name'::text, integration.name)), ',') as integration_name 
            FROM project_integrations AS integration 
            WHERE integration.project_id = p.id
        ) as integrations
    FROM projects p
    JOIN users u ON p.user_id = u.id
    LEFT JOIN project_score_storages pss ON pss.project_id = p.id
    LEFT JOIN project_metric_storages pms ON pms.project_id = p.id
    LEFT JOIN cities c ON c.id = p.city_id
    LEFT JOIN states s ON s.id = c.state_id
    JOIN LATERAL zone_timestamp(online_at(p.*)) od(od) ON true
    JOIN LATERAL state_order(p.*) so(so) ON true
    LEFT JOIN categories category ON category.id = p.category_id;
    
    grant select on "1"."projects" to admin, anonymous, web_user;

    grant select on public.project_integrations to admin, anonymous, web_user;

    SQL
  end
end
