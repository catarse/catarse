class ReplaceProjectDetailsAndDropOldImgFunction < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE VIEW "1".project_details AS 
       SELECT p.id AS project_id,
          p.id,
          p.user_id,
          p.name,
          p.headline,
          p.budget,
          p.goal,
          p.about_html,
          p.permalink,
          p.video_embed_url,
          p.video_url,
          c.name_pt AS category_name,
          c.id AS category_id,
          original_image(p.*) AS original_image,
          thumbnail_image(p.*, 'thumb'::text) AS thumb_image,
          thumbnail_image(p.*, 'small'::text) AS small_image,
          thumbnail_image(p.*, 'large'::text) AS large_image,
          thumbnail_image(p.*, 'video_cover'::text) AS video_cover_image,
          COALESCE(pt.progress, 0::numeric) AS progress,
          COALESCE(pt.pledged, 0::numeric) AS pledged,
          COALESCE(pt.total_contributions, 0::bigint) AS total_contributions,
          p.state,
          p.expires_at,
          zone_expires_at(p.*) AS zone_expires_at,
          p.online_date,
          p.sent_to_analysis_at,
          is_published(p.*) AS is_published,
          is_expired(p.*) AS is_expired,
          open_for_contributions(p.*) AS open_for_contributions,
          p.online_days,
          remaining_time_json(p.*) AS remaining_time,
          ( SELECT count(pp_1.*) AS count
                 FROM project_posts pp_1
                WHERE pp_1.project_id = p.id) AS posts_count,
          json_build_object('city', COALESCE(ct.name, u.address_city), 'state_acronym', COALESCE(st.acronym, u.address_state::character varying), 'state', COALESCE(st.name, u.address_state::character varying)) AS address,
          json_build_object('id', u.id, 'name', u.name) AS "user",
          count(DISTINCT pn.*) FILTER (WHERE pn.template_name = 'reminder'::text) AS reminder_count,
          is_owner_or_admin(p.user_id) AS is_owner_or_admin,
          user_signed_in() AS user_signed_in,
          current_user_already_in_reminder(p.*) AS in_reminder,
          count(pp.*) AS total_posts,
          "current_user"() = 'admin'::name AS is_admin_role
         FROM projects p
           JOIN categories c ON c.id = p.category_id
           JOIN users u ON u.id = p.user_id
           LEFT JOIN project_posts pp ON pp.project_id = p.id
           LEFT JOIN "1".project_totals pt ON pt.project_id = p.id
           LEFT JOIN cities ct ON ct.id = p.city_id
           LEFT JOIN states st ON st.id = ct.state_id
           LEFT JOIN project_notifications pn ON pn.project_id = p.id
        GROUP BY p.id, c.id, u.id, c.name_pt, ct.name, u.address_city, st.acronym, u.address_state, st.name, pt.progress, pt.pledged, pt.total_contributions, p.state, p.expires_at, p.sent_to_analysis_at, pt.total_payment_service_fee;

      DROP FUNCTION public.img_thumbnail(projects, text);
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

      CREATE OR REPLACE VIEW "1".project_details AS 
       SELECT p.id AS project_id,
          p.id,
          p.user_id,
          p.name,
          p.headline,
          p.budget,
          p.goal,
          p.about_html,
          p.permalink,
          p.video_embed_url,
          p.video_url,
          c.name_pt AS category_name,
          c.id AS category_id,
          original_image(p.*) AS original_image,
          img_thumbnail(p.*, 'thumb'::text) AS thumb_image,
          img_thumbnail(p.*, 'small'::text) AS small_image,
          img_thumbnail(p.*, 'large'::text) AS large_image,
          img_thumbnail(p.*, 'video_cover'::text) AS video_cover_image,
          COALESCE(pt.progress, 0::numeric) AS progress,
          COALESCE(pt.pledged, 0::numeric) AS pledged,
          COALESCE(pt.total_contributions, 0::bigint) AS total_contributions,
          p.state,
          p.expires_at,
          zone_expires_at(p.*) AS zone_expires_at,
          p.online_date,
          p.sent_to_analysis_at,
          is_published(p.*) AS is_published,
          is_expired(p.*) AS is_expired,
          open_for_contributions(p.*) AS open_for_contributions,
          p.online_days,
          remaining_time_json(p.*) AS remaining_time,
          ( SELECT count(pp_1.*) AS count
                 FROM project_posts pp_1
                WHERE pp_1.project_id = p.id) AS posts_count,
          json_build_object('city', COALESCE(ct.name, u.address_city), 'state_acronym', COALESCE(st.acronym, u.address_state::character varying), 'state', COALESCE(st.name, u.address_state::character varying)) AS address,
          json_build_object('id', u.id, 'name', u.name) AS "user",
          count(DISTINCT pn.*) FILTER (WHERE pn.template_name = 'reminder'::text) AS reminder_count,
          is_owner_or_admin(p.user_id) AS is_owner_or_admin,
          user_signed_in() AS user_signed_in,
          current_user_already_in_reminder(p.*) AS in_reminder,
          count(pp.*) AS total_posts,
          "current_user"() = 'admin'::name AS is_admin_role
         FROM projects p
           JOIN categories c ON c.id = p.category_id
           JOIN users u ON u.id = p.user_id
           LEFT JOIN project_posts pp ON pp.project_id = p.id
           LEFT JOIN "1".project_totals pt ON pt.project_id = p.id
           LEFT JOIN cities ct ON ct.id = p.city_id
           LEFT JOIN states st ON st.id = ct.state_id
           LEFT JOIN project_notifications pn ON pn.project_id = p.id
        GROUP BY p.id, c.id, u.id, c.name_pt, ct.name, u.address_city, st.acronym, u.address_state, st.name, pt.progress, pt.pledged, pt.total_contributions, p.state, p.expires_at, p.sent_to_analysis_at, pt.total_payment_service_fee;

    SQL
  end
end
