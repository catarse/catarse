class CoalescePledgedAndProgressInProjectsView < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.thumbnail_image(projects, size text)
       RETURNS text
       LANGUAGE sql
       STABLE
      AS $function$
                SELECT
                  'https://' || settings('aws_host')  ||
                  '/' || settings('aws_bucket') ||
                  '/uploads/project/uploaded_image/' || $1.id::text ||
                  '/project_thumb_' || size || '_' || $1.uploaded_image
            $function$;

      CREATE OR REPLACE FUNCTION public.thumbnail_image(projects)
       RETURNS text
       LANGUAGE sql
       STABLE
      AS $function$
        SELECT public.thumbnail_image($1, 'small');
      $function$;

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
          coalesce(( SELECT pt.pledged
                 FROM "1".project_totals pt
                WHERE pt.project_id = p.id), 0) AS pledged,
          coalesce(( SELECT pt.progress
                 FROM "1".project_totals pt
                WHERE pt.project_id = p.id), 0) AS progress,
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

  def down
    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.img_thumbnail(projects, size text)
       RETURNS text
       LANGUAGE sql
       STABLE
      AS $function$
                SELECT
                  'https://' || settings('aws_host')  ||
                  '/' || settings('aws_bucket') ||
                  '/uploads/project/uploaded_image/' || $1.id::text ||
                  '/project_thumb_' || size || '_' || $1.uploaded_image
            $function$;

      CREATE OR REPLACE VIEW "1".projects AS
       SELECT p.id AS project_id,
          p.name AS project_name,
          p.headline,
          p.permalink,
          p.state,
          p.online_date,
          p.recommended,
          img_thumbnail(p.*, 'large'::text) AS project_img,
          remaining_time_json(p.*) AS remaining_time,
          p.expires_at,
          ( SELECT pt.pledged
                 FROM "1".project_totals pt
                WHERE pt.project_id = p.id) AS pledged,
          ( SELECT pt.progress
                 FROM "1".project_totals pt
                WHERE pt.project_id = p.id) AS progress,
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
