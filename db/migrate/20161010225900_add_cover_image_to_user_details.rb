class AddCoverImageToUserDetails < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE OR REPLACE FUNCTION cover_image_url(users) RETURNS text
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
            SELECT
              'https://' || (SELECT value FROM settings WHERE name = 'aws_host') ||
              '/' || (SELECT value FROM settings WHERE name = 'aws_bucket') ||
              '/uploads/user/cover_image/' || $1.id::text ||
              '/base_' || $1.cover_image
            $_$;

    CREATE OR REPLACE VIEW "1".user_details AS
      SELECT u.id,
        u.name,
        u.address_city,
        u.deactivated_at,
        thumbnail_image(u.*) AS profile_img_thumbnail,
        u.facebook_link,
        u.twitter AS twitter_username,
            CASE
                WHEN is_owner_or_admin(u.id) THEN u.email
                ELSE NULL::text
            END AS email,
        COALESCE(ut.total_contributed_projects, 0::bigint) AS total_contributed_projects,
        COALESCE(ut.total_published_projects, 0::bigint) AS total_published_projects,
        ( SELECT json_agg(DISTINCT ul.link) AS json_agg
               FROM user_links ul
              WHERE ul.user_id = u.id) AS links,
        (select count(*) from user_follows uf WHERE user_id = u.id) AS follows_count,
        (select count(*) from user_follows uf WHERE follow_id = u.id) AS followers_count,
        (CASE
             WHEN public.is_owner_or_admin(u.id) THEN
               json_build_object('street', u.address_street, 'number', u.address_number, 'complement', u.address_complement, 'neighbourhood', u.address_neighbourhood, 'city', u.address_city, 'state', u.address_state, 'zipcode', u.address_zip_code, 'phonenumber', u.phone_number, 'country_id', u.country_id)
             ELSE NULL::json
         END) AS address,
        (CASE
            WHEN public.is_owner_or_admin(u.id) THEN u.cpf
            ELSE NULL::text
         END) AS owner_document,
       cover_image_url(u.*) AS profile_cover_image,
       u.created_at,
       u.about_html,
       is_owner_or_admin(u.id) AS is_owner_or_admin
       FROM users u
         LEFT JOIN "1".user_totals ut ON ut.user_id = u.id;

       GRANT SELECT ON "1".user_details to admin;
       GRANT SELECT ON "1".user_details to web_user;
       GRANT SELECT ON "1".user_details to anonymous;
    SQL
  end
  def down
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
                WHEN is_owner_or_admin(u.id) THEN u.email
                ELSE NULL::text
            END AS email,
        COALESCE(ut.total_contributed_projects, 0::bigint) AS total_contributed_projects,
        COALESCE(ut.total_published_projects, 0::bigint) AS total_published_projects,
        ( SELECT json_agg(DISTINCT ul.link) AS json_agg
               FROM user_links ul
              WHERE ul.user_id = u.id) AS links,
        (select count(*) from user_follows uf WHERE user_id = u.id) AS follows_count,
        (select count(*) from user_follows uf WHERE follow_id = u.id) AS followers_count,
        (CASE
             WHEN public.is_owner_or_admin(u.id) THEN
               json_build_object('street', u.address_street, 'number', u.address_number, 'complement', u.address_complement, 'neighbourhood', u.address_neighbourhood, 'city', u.address_city, 'state', u.address_state, 'zipcode', u.address_zip_code, 'phonenumber', u.phone_number, 'country_id', u.country_id)
             ELSE NULL::json
         END) AS address,
        (CASE
            WHEN public.is_owner_or_admin(u.id) THEN u.cpf
            ELSE NULL::text
         END) AS owner_document
       FROM users u
         LEFT JOIN "1".user_totals ut ON ut.user_id = u.id;

       GRANT SELECT ON "1".user_details to admin;
       GRANT SELECT ON "1".user_details to web_user;
       GRANT SELECT ON "1".user_details to anonymous;
    SQL
  end

end
