class FixThumbnailFunction < ActiveRecord::Migration
  def change
    execute <<-SQL
    CREATE OR REPLACE FUNCTION thumbnail_image(projects, size text) RETURNS text
    LANGUAGE sql STABLE
    AS $_$
              SELECT
                'https://'
                || settings('aws_host')
                || '/'
                || settings('aws_bucket')
                || '/uploads/project/'
                || (CASE WHEN $1.uploaded_image IS NOT NULL THEN 'uploaded_image/' ELSE 'video_thumbnail/' END)::text
                || $1.id::text
                || '/project_thumb_'
                || COALESCE(nullif(size,'') || '_', '')
                || COALESCE($1.uploaded_image, $1.video_thumbnail)
          $_$;

    
    SQL
  end
end
