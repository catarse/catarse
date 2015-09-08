class CreateProjectsView < ActiveRecord::Migration
  def up
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

      CREATE OR REPLACE VIEW "1".projects as
        select
        p.id AS project_id,
        p.name AS project_name,
        p.headline,
        p.permalink,
        p.state,
        p.created_at,
        img_thumbnail(p.*,'large') AS project_img,
        p.remaining_time_json as remaining_time,
        p.expires_at,
        pt.pledged,
        pt.progress,
        u.name AS owner_name,
        c.name AS city_name
        FROM(
          projects p
          JOIN users u ON (p.user_id = u.id)
          LEFT JOIN "1".project_totals pt ON (pt.project_id = p.id)
          LEFT JOIN cities c ON (c.id = p.city_id)

        )
         ;
      grant select on "1".projects to anonymous;
      grant select on "1".projects to web_user;
      grant select on "1".projects to admin;
    SQL
  end

  def down
    execute <<-SQL
      drop view "1".projects
    SQL
  end
end
