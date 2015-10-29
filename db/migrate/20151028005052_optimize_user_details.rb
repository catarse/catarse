class OptimizeUserDetails < ActiveRecord::Migration
  def up
    execute <<-SQL
      DROP VIEW "1".user_details;

      CREATE VIEW "1".user_full_details AS
        SELECT u.id,
          u.name,
          u.address_city,
          u.deactivated_at,
          thumbnail_image(u.*) AS profile_img_thumbnail,
          u.facebook_link,
          u.full_text_index,
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

      CREATE VIEW "1".user_details AS
        SELECT id,
          name,
          address_city,
          deactivated_at,
          profile_img_thumbnail,
          facebook_link,
          twitter_username,
          email,
          total_contributed_projects,
          total_published_projects,
          links
        FROM "1".user_full_details;

      CREATE INDEX users_full_text_index_ix ON users USING gin (full_text_index);
      GRANT SELECT ON "1".user_details TO public;
      GRANT SELECT ON "1".user_full_details TO admin;
    SQL
  end

  def down
    execute <<-SQL
      DROP VIEW "1".user_details;

      CREATE VIEW "1".user_details AS
        SELECT u.id,
          u.name,
          u.address_city,
          u.deactivated_at,
          thumbnail_image(u.*) AS profile_img_thumbnail,
          u.facebook_link,
          CASE
                  WHEN is_owner_or_admin(u.id) THEN u.full_text_index
                  ELSE NULL
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

      GRANT SELECT ON "1".user_details TO public;

      DROP VIEW "1".user_full_details;
      DROP INDEX users_full_text_index_ix;
    SQL
  end
end
