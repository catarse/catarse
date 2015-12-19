class OptimizeProjectsView < ActiveRecord::Migration
  def change
    execute <<-SQL
CREATE OR REPLACE VIEW "1".projects AS
 SELECT p.id AS project_id,
    p.category_id,
    p.name AS project_name,
    p.headline,
    p.permalink,
    mode(p.*) AS mode,
    COALESCE(fp.state, p.state::text) AS state,
    so AS state_order,
    od AS online_date,
    p.recommended,
    thumbnail_image(p.*, 'large'::text) AS project_img,
    remaining_time_json(p.*) AS remaining_time,
    p.expires_at,
    COALESCE(( SELECT pt.pledged
           FROM "1".project_totals pt
          WHERE pt.project_id = p.id), 0::numeric) AS pledged,
    COALESCE(( SELECT pt.progress
           FROM "1".project_totals pt
          WHERE pt.project_id = p.id), 0::numeric) AS progress,
    COALESCE(s.acronym, pa.address_state::character varying(255)) AS state_acronym,
    u.name AS owner_name,
    COALESCE(c.name, pa.address_city) AS city_name,
    p.full_text_index,
    is_current_and_online(p.expires_at, COALESCE(fp.state, p.state::text)) AS open_for_contributions
   FROM projects p
     JOIN users u ON p.user_id = u.id
     JOIN LATERAL zone_timestamp(online_at(p.*)) od ON true
     JOIN LATERAL state_order(p.*) so ON true
     LEFT JOIN flexible_projects fp ON fp.project_id = p.id
     LEFT JOIN project_accounts pa ON pa.project_id = p.id
     LEFT JOIN cities c ON c.id = p.city_id
     LEFT JOIN states s ON s.id = c.state_id
    SQL
  end
end
