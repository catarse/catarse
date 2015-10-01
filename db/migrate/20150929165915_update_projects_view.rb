class UpdateProjectsView < ActiveRecord::Migration
  def change
    execute "
      drop function if exists public.near_me(projects) cascade;
      DROP VIEW \"1\".projects cascade;
      CREATE OR REPLACE VIEW \"1\".projects AS
        SELECT p.id AS project_id,
        p.name AS project_name,
        p.headline,
        p.category_id,
        p.permalink,
        p.state,
        p.online_date,
        p.recommended,
        thumbnail_image(p.*, 'large'::text) AS project_img,
        remaining_time_json(p.*) AS remaining_time,
        p.expires_at,
        COALESCE(( SELECT pt.pledged
               FROM \"1\".project_totals pt
              WHERE pt.project_id = p.id), 0::numeric) AS pledged,
        COALESCE(( SELECT pt.progress
               FROM \"1\".project_totals pt
              WHERE pt.project_id = p.id), 0::numeric) AS progress,
        COALESCE(s.acronym, pa.address_state::character varying(255)) AS state_acronym,
        u.name AS owner_name,
        COALESCE(c.name, pa.address_city) AS city_name
       FROM projects p
         JOIN users u ON p.user_id = u.id
         LEFT JOIN project_accounts pa ON pa.project_id = p.id
         LEFT JOIN cities c ON c.id = p.city_id
         LEFT JOIN states s ON s.id = c.state_id
      WHERE p.is_published
      ORDER BY random();
      grant select on \"1\".projects to admin;
      grant select on \"1\".projects to web_user;
      grant select on \"1\".projects to anonymous;

      CREATE OR REPLACE FUNCTION public.near_me(\"1\".projects)
       RETURNS boolean
       LANGUAGE sql
       STABLE SECURITY DEFINER
      AS $function$
        SELECT 
    COALESCE($1.state_acronym, (SELECT pa.address_state FROM project_accounts pa WHERE pa.project_id = $1.project_id)) = (SELECT u.address_state FROM users u WHERE u.id = nullif(current_setting('user_vars.user_id'), '')::int)
      $function$
        "
  end
end
