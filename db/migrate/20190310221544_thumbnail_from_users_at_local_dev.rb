class ThumbnailFromUsersAtLocalDev < ActiveRecord::Migration
  def up
    add_column :rewards, :uploaded_image, :string
    execute <<-SQL

    CREATE OR REPLACE FUNCTION public.thumbnail_image(projects)
    RETURNS text
    LANGUAGE sql
    STABLE
  AS $function$
          SELECT public.thumbnail_image($1, 'small');
        $function$
  ;
  ---
  
  CREATE OR REPLACE FUNCTION public.thumbnail_image(users)
    RETURNS text
    LANGUAGE sql
    STABLE SECURITY DEFINER
  AS $function$
      SELECT
          COALESCE(
                      (
                          'https://' || (SELECT value FROM settings WHERE name = 'aws_host') ||
                          '/' || (SELECT value FROM settings WHERE name = 'aws_bucket') ||
                          '/uploads/user/uploaded_image/' || $1.id::text ||
                          '/thumb_avatar_' || $1.uploaded_image
                      ),
                      '/uploads/user/uploaded_image/' || $1.id::text || '/thumb_avatar_' || $1.uploaded_image
                  )
                  
  $function$
  ;
  ---
  
  CREATE OR REPLACE FUNCTION public.thumbnail_image(projects, size text)
    RETURNS text
    LANGUAGE sql
    STABLE
  AS $function$
      SELECT
          COALESCE(
              (
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
              ),
              '/uploads/project/'
                  || (CASE WHEN $1.uploaded_image IS NOT NULL THEN 'uploaded_image/' ELSE 'video_thumbnail/' END)::text
                  || $1.id::text
                  || '/project_thumb_'
                  || COALESCE(nullif(size,'') || '_', '')
                  || COALESCE($1.uploaded_image, $1.video_thumbnail)        
          )
  
      $function$
      ;
      ---
      
      CREATE OR REPLACE FUNCTION public.thumbnail_image(rewards)
        RETURNS text
        LANGUAGE sql
        STABLE SECURITY DEFINER
      AS $function$
          SELECT
              COALESCE(
                          (
                              'https://' || (SELECT value FROM settings WHERE name = 'aws_host') ||
                              '/' || (SELECT value FROM settings WHERE name = 'aws_bucket') ||
                              '/uploads/reward/uploaded_image/' || $1.id::text ||
                              '/thumb_reward_' || $1.uploaded_image
                          ),
                          '/uploads/reward/uploaded_image/' || $1.id::text || '/thumb_reward_' || $1.uploaded_image
                      )
                      
      $function$
      ;
      ---

  SQL

  end

  def down

    execute <<-SQL

    CREATE OR REPLACE FUNCTION public.thumbnail_image(projects)
        RETURNS text
        LANGUAGE sql
        STABLE
      AS $function$
              SELECT public.thumbnail_image($1, 'small');
            $function$
      ;
      ---
      
      CREATE OR REPLACE FUNCTION public.thumbnail_image(users)
        RETURNS text
        LANGUAGE sql
        STABLE SECURITY DEFINER
      AS $function$
          SELECT
            'https://' || (SELECT value FROM settings WHERE name = 'aws_host') ||
            '/' || (SELECT value FROM settings WHERE name = 'aws_bucket') ||
            '/uploads/user/uploaded_image/' || $1.id::text ||
            '/thumb_avatar_' || $1.uploaded_image
                      
      $function$
      ;
      ---
      
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
            || COALESCE(nullif(size,'') || '_', '')
            || COALESCE($1.uploaded_image, $1.video_thumbnail)        
      
      $function$;;
   

    SQL
    remove_column :rewards, :uploaded_image

  end
end
