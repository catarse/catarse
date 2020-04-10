class AdjustScoreCalculations < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE OR REPLACE VIEW "1"."project_scores" AS 
 SELECT p.id AS project_id,
        CASE
            WHEN (p.mode = 'sub'::text) THEN (lt_sub.score)::numeric
            ELSE (lt_non_sub.score)::numeric
        END AS score
   FROM ((projects p
     LEFT JOIN LATERAL ( SELECT count(DISTINCT c.id) AS score
           FROM (contributions c
             LEFT JOIN payments pay ON ((pay.contribution_id = c.id)))
          WHERE (((pay.state = ANY (confirmed_states())) AND (pay.paid_at > (now() - '48:00:00'::interval))) AND (c.project_id = p.id))) lt_non_sub ON (true))
     LEFT JOIN LATERAL ( SELECT count(DISTINCT s.id) AS score
           FROM (common_schema.subscriptions s
             LEFT JOIN common_schema.catalog_payments cp ON ((cp.subscription_id = s.id)))
          WHERE (((cp.status = 'paid'::payment_service.payment_status) AND (cp.created_at > (now() - '48:00:00'::interval))) AND (s.project_id = p.common_id))) lt_sub ON (true))
  WHERE open_for_contributions(p.*);


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
    (EXISTS ( SELECT true AS bool
           FROM project_reminders pr
          WHERE ((p.id = pr.project_id) AND (pr.user_id = current_user_id())))) AS saved_projects
   FROM (((((((projects p
     JOIN users u ON ((p.user_id = u.id)))
     LEFT JOIN project_score_storages pss ON ((pss.project_id = p.id)))
     LEFT JOIN project_metric_storages pms ON ((pms.project_id = p.id)))
     LEFT JOIN cities c ON ((c.id = p.city_id)))
     LEFT JOIN states s ON ((s.id = c.state_id)))
     JOIN LATERAL zone_timestamp(online_at(p.*)) od(od) ON (true))
     JOIN LATERAL state_order(p.*) so(so) ON (true));
    SQL
  end

  def down
    execute <<-SQL
CREATE OR REPLACE VIEW "1"."project_scores" AS 
 SELECT p.id AS project_id,
        CASE
            WHEN (p.mode = 'sub'::text) THEN
            CASE
                WHEN p.recommended THEN (COALESCE((lt_sub.score)::numeric, (0)::numeric) + (1000)::numeric)
                ELSE (lt_sub.score)::numeric
            END
            ELSE (lt_non_sub.score)::numeric
        END AS score
   FROM ((projects p
     LEFT JOIN LATERAL ( SELECT count(DISTINCT c.id) AS score
           FROM (contributions c
             LEFT JOIN payments pay ON ((pay.contribution_id = c.id)))
          WHERE (((pay.state = ANY (confirmed_states())) AND (pay.paid_at > (now() - '48:00:00'::interval))) AND (c.project_id = p.id))) lt_non_sub ON (true))
     LEFT JOIN LATERAL ( SELECT count(DISTINCT s.id) AS score
           FROM (common_schema.subscriptions s
             LEFT JOIN common_schema.catalog_payments cp ON ((cp.subscription_id = s.id)))
          WHERE (((cp.status = 'paid'::payment_service.payment_status) AND (cp.created_at > (now() - '48:00:00'::interval))) AND (s.project_id = p.common_id))) lt_sub ON (true))
  WHERE open_for_contributions(p.*);


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
    (pss.score)::numeric AS score,
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
    (EXISTS ( SELECT true AS bool
           FROM project_reminders pr
          WHERE ((p.id = pr.project_id) AND (pr.user_id = current_user_id())))) AS saved_projects
   FROM (((((((projects p
     JOIN users u ON ((p.user_id = u.id)))
     LEFT JOIN project_score_storages pss ON ((pss.project_id = p.id)))
     LEFT JOIN project_metric_storages pms ON ((pms.project_id = p.id)))
     LEFT JOIN cities c ON ((c.id = p.city_id)))
     LEFT JOIN states s ON ((s.id = c.state_id)))
     JOIN LATERAL zone_timestamp(online_at(p.*)) od(od) ON (true))
     JOIN LATERAL state_order(p.*) so(so) ON (true));
    SQL
  end
end
