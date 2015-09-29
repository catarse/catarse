class CoalescesCityAndStateInProjectsView < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE VIEW "1".projects AS
       SELECT p.id AS project_id,
          p.name AS project_name,
          p.headline,
          p.permalink,
          p.state,
          p.online_date,
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
          coalesce(s.acronym, pa.address_state::varchar(255)) AS state_acronym,
          u.name AS owner_name,
          coalesce(c.name, pa.address_city) AS city_name
         FROM public.projects p
           JOIN users u ON p.user_id = u.id
           LEFT JOIN project_accounts pa ON pa.project_id = p.id
           LEFT JOIN cities c ON c.id = p.city_id
           LEFT JOIN states s ON s.id = c.state_id
        ORDER BY random();
    SQL
  end

  def down
    execute <<-SQL
      CREATE OR REPLACE VIEW "1".projects AS
       SELECT p.id AS project_id,
          p.name AS project_name,
          p.headline,
          p.permalink,
          p.state,
          p.online_date,
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
          s.acronym AS state_acronym,
          u.name AS owner_name,
          c.name AS city_name
         FROM public.projects p
           JOIN users u ON p.user_id = u.id
           LEFT JOIN cities c ON c.id = p.city_id
           LEFT JOIN states s ON s.id = c.state_id
        ORDER BY random();
    SQL
  end
end
