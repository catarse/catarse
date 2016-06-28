class FixesProjectThumbFunction < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE OR REPLACE FUNCTION public.thumbnail_image(projects, size text)
     RETURNS text
     LANGUAGE sql
     STABLE
    AS $function$
              SELECT
                'https://'
                || settings('aws_host')
                || '/'
                || settings('aws_bucket')
                || '/uploads/project/'
                || (CASE WHEN $1.uploaded_image IS NOT NULL THEN 'uploaded_image/' ELSE 'video_thumbnail/' END)::text
                || $1.id::text
                || '/project_thumb_'
                || size
                || '_'
                || COALESCE($1.uploaded_image, $1.video_thumbnail)
          $function$;
    SQL
  end
  def down
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
    SQL
  end
end
