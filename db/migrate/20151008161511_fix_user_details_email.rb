class FixUserDetailsEmail < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE OR REPLACE VIEW "1".user_details AS
 SELECT u.id,
    u.name,
    u.address_city,
    thumbnail_image(u.*) AS profile_img_thumbnail,
    u.facebook_link,
        CASE
            WHEN is_owner_or_admin(u.id) THEN u.full_text_index
            ELSE NULL::tsvector
        END AS full_text_index,
    u.twitter AS twitter_username,
        CASE
            WHEN is_owner_or_admin(u.id) OR (has_published_projects(u.*) AND current_user <> 'anonymous') THEN u.email
            ELSE NULL::text
        END AS email,
    COALESCE(ut.total_contributed_projects, 0::bigint) AS total_contributed_projects,
    COALESCE(ut.total_published_projects, 0::bigint) AS total_published_projects,
    ( SELECT json_agg(DISTINCT ul.link) AS json_agg
           FROM user_links ul
          WHERE ul.user_id = u.id) AS links
   FROM users u
     LEFT JOIN "1".user_totals ut ON ut.user_id = u.id;
    SQL
  end

  def down
    execute <<-SQL
CREATE OR REPLACE VIEW "1".user_details AS
 SELECT u.id,
    u.name,
    u.address_city,
    thumbnail_image(u.*) AS profile_img_thumbnail,
    u.facebook_link,
        CASE
            WHEN is_owner_or_admin(u.id) THEN u.full_text_index
            ELSE NULL::tsvector
        END AS full_text_index,
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
   FROM users u
     LEFT JOIN "1".user_totals ut ON ut.user_id = u.id;
    SQL
  end
end
