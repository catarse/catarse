class RemoveRandomOrderFromApiProjects < ActiveRecord::Migration
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
    COALESCE(s.acronym, pa.address_state::character varying(255)) AS state_acronym,
    u.name AS owner_name,
    COALESCE(c.name, pa.address_city) AS city_name
   FROM public.projects p
     JOIN public.users u ON p.user_id = u.id
     LEFT JOIN public.project_accounts pa ON pa.project_id = p.id
     LEFT JOIN public.cities c ON c.id = p.city_id
     LEFT JOIN public.states s ON s.id = c.state_id;
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
    COALESCE(s.acronym, pa.address_state::character varying(255)) AS state_acronym,
    u.name AS owner_name,
    COALESCE(c.name, pa.address_city) AS city_name
   FROM public.projects p
     JOIN public.users u ON p.user_id = u.id
     LEFT JOIN public.project_accounts pa ON pa.project_id = p.id
     LEFT JOIN public.cities c ON c.id = p.city_id
     LEFT JOIN public.states s ON s.id = c.state_id
  ORDER BY random();
    SQL
  end
end
