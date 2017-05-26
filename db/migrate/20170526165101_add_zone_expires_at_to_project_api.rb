class AddZoneExpiresAtToProjectApi < ActiveRecord::Migration
  def change
    execute %Q{
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
                    WHEN ((p.state)::text = 'failed'::text) THEN pt.pledged
                    ELSE pt.paid_pledged
                END AS paid_pledged
           FROM "1".project_totals pt
          WHERE (pt.project_id = p.id)), (0)::numeric) AS pledged,
    COALESCE(( SELECT pt.progress
           FROM "1".project_totals pt
          WHERE (pt.project_id = p.id)), (0)::numeric) AS progress,
    s.acronym AS state_acronym,
    u.name AS owner_name,
    c.name AS city_name,
    p.full_text_index,
    is_current_and_online(p.expires_at, (p.state)::text) AS open_for_contributions,
    elapsed_time_json(p.*) AS elapsed_time,
    score(p.*) AS score,
    (EXISTS ( SELECT true AS bool
           FROM (contributions c_1
             JOIN user_follows uf ON ((uf.follow_id = c_1.user_id)))
          WHERE (is_confirmed(c_1.*) AND (uf.user_id = current_user_id()) AND (c_1.project_id = p.id)))) AS contributed_by_friends,
    p.user_id AS project_user_id,
    p.video_embed_url,
    p.updated_at,
    u.public_name AS owner_public_name,
    zone_timestamp(p.expires_at) AS zone_expires_at    
   FROM (((((projects p
     JOIN users u ON ((p.user_id = u.id)))
     LEFT JOIN cities c ON ((c.id = p.city_id)))
     LEFT JOIN states s ON ((s.id = c.state_id)))
     JOIN LATERAL zone_timestamp(online_at(p.*)) od(od) ON (true))
     JOIN LATERAL state_order(p.*) so(so) ON (true));
}
  end
end
