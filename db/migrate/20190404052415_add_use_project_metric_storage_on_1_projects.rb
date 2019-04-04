class AddUseProjectMetricStorageOn1Projects < ActiveRecord::Migration
  def up
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
    COALESCE((pms.data->>'pledged')::numeric, (0)::numeric) AS pledged,
    COALESCE((pms.data->>'progress')::numeric, (0)::numeric) AS progress,
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
    p.common_id
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
    COALESCE(( SELECT
                CASE
                    WHEN (p.mode = 'sub'::text) THEN ( SELECT sum((((s_1.checkout_data ->> 'amount'::text))::numeric / (100)::numeric)) AS sum
                       FROM common_schema.subscriptions s_1
                      WHERE ((s_1.project_id = p.common_id) AND ((s_1.status)::text = 'active'::text)))
                    ELSE ( SELECT
                            CASE
                                WHEN ((p.state)::text = 'failed'::text) THEN pt.pledged
                                ELSE pt.paid_pledged
                            END AS paid_pledged
                       FROM "1".project_totals pt
                      WHERE (pt.project_id = p.id))
                END AS paid_pledged), (0)::numeric) AS pledged,
    COALESCE(( SELECT
                CASE
                    WHEN (p.mode = 'sub'::text) THEN ((( SELECT sum((((s_1.checkout_data ->> 'amount'::text))::numeric / (100)::numeric)) AS sum
                       FROM common_schema.subscriptions s_1
                      WHERE ((s_1.project_id = p.common_id) AND ((s_1.status)::text = 'active'::text))) / COALESCE(( SELECT min(g.value) AS min
                       FROM goals g
                      WHERE ((g.project_id = p.id) AND (g.value > ( SELECT total_amount.sum
                               FROM ( SELECT sum((((s_2.checkout_data ->> 'amount'::text))::numeric / (100)::numeric)) AS sum
                                       FROM common_schema.subscriptions s_2
                                      WHERE ((s_2.project_id = p.common_id) AND ((s_2.status)::text = 'active'::text))) total_amount)))
                     LIMIT 1), ( SELECT max(goals.value) AS max
                       FROM goals
                      WHERE (goals.project_id = p.id)))) * (100)::numeric)
                    ELSE ( SELECT pt.progress
                       FROM "1".project_totals pt
                      WHERE (pt.project_id = p.id))
                END AS progress), (0)::numeric) AS progress,
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
    p.common_id
   FROM ((((((projects p
     JOIN users u ON ((p.user_id = u.id)))
     LEFT JOIN project_score_storages pss ON ((pss.project_id = p.id)))
     LEFT JOIN cities c ON ((c.id = p.city_id)))
     LEFT JOIN states s ON ((s.id = c.state_id)))
     JOIN LATERAL zone_timestamp(online_at(p.*)) od(od) ON (true))
     JOIN LATERAL state_order(p.*) so(so) ON (true));
    SQL
  end
end
