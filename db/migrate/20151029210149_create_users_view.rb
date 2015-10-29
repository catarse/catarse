class CreateUsersView < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE VIEW "1".users AS
        SELECT u.id,
          u.name,
          thumbnail_image(u.*) AS profile_img_thumbnail,
          u.facebook_link,
          u.twitter AS twitter_username,
          CASE
              WHEN is_owner_or_admin(u.id) OR has_published_projects(u.*) THEN u.email
              ELSE NULL::text
          END AS email,
          u.deactivated_at,
          u.full_text_index
         FROM users u;
      GRANT SELECT ON "1".users TO admin;
      GRANT UPDATE (deactivated_at) ON "1".users, public.users TO admin;
    SQL
  end

  def down
    execute <<-SQL
    DROP VIEW "1".users;
    SQL
  end
end
