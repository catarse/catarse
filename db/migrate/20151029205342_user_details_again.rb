class UserDetailsAgain < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE OR REPLACE VIEW "1".user_details AS
    SELECT u.id,
        u.name,
        u.address_city,
        u.deactivated_at,
        thumbnail_image(u.*) AS profile_img_thumbnail,
        u.facebook_link,
        u.twitter AS twitter_username,
        CASE
            WHEN is_owner_or_admin(u.id) OR has_published_projects(u.*) THEN u.email
            ELSE NULL::text
        END AS email,
        COALESCE(ut.total_contributed_projects, 0::bigint) AS total_contributed_projects,
        COALESCE(ut.total_published_projects, 0::bigint) AS total_published_projects,
        ( SELECT json_agg(DISTINCT ul.link) AS json_agg
            FROM user_links ul
            WHERE ul.user_id = u.id) AS links
    FROM public.users u
        LEFT JOIN "1".user_totals ut ON ut.user_id = u.id;
    SQL
  end

  def down
    execute <<-SQL
    CREATE OR REPLACE VIEW "1".user_details AS
    SELECT user_full_details.id,
        user_full_details.name,
        user_full_details.address_city,
        user_full_details.deactivated_at,
        user_full_details.profile_img_thumbnail,
        user_full_details.facebook_link,
        user_full_details.twitter_username,
        user_full_details.email,
        user_full_details.total_contributed_projects,
        user_full_details.total_published_projects,
        user_full_details.links
    FROM "1".user_full_details;
   SQL
  end
end
