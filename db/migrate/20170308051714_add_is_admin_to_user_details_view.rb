class AddIsAdminToUserDetailsView < ActiveRecord::Migration
  def change
    execute %Q{
CREATE OR REPLACE VIEW "1"."user_details" AS 
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
    COALESCE(ut.total_contributed_projects, (0)::bigint) AS total_contributed_projects,
    COALESCE(ut.total_published_projects, (0)::bigint) AS total_published_projects,
    ( SELECT json_agg(links.*) AS json_agg
           FROM ( SELECT ul.id,
                    ul.link
                   FROM user_links ul
                  WHERE (ul.user_id = u.id)) links) AS links,
    ( SELECT count(*) AS count
           FROM user_follows uf
          WHERE (uf.user_id = u.id)) AS follows_count,
    ( SELECT count(*) AS count
           FROM user_follows uf
          WHERE (uf.follow_id = u.id)) AS followers_count,
        CASE
            WHEN is_owner_or_admin(u.id) THEN json_build_object('street', u.address_street, 'number', u.address_number, 'complement', u.address_complement, 'neighbourhood', u.address_neighbourhood, 'city', u.address_city, 'state', u.address_state, 'zipcode', u.address_zip_code, 'phonenumber', u.phone_number, 'country_id', u.country_id)
            ELSE NULL::json
        END AS address,
        CASE
            WHEN is_owner_or_admin(u.id) THEN u.cpf
            ELSE NULL::text
        END AS owner_document,
    cover_image_url(u.*) AS profile_cover_image,
    u.created_at,
    u.about_html,
    is_owner_or_admin(u.id) AS is_owner_or_admin,
    u.newsletter,
    u.subscribed_to_project_posts,
    u.subscribed_to_new_followers,
    u.subscribed_to_friends_contributions,
    ("current_user"() = 'admin'::name) AS is_admin,
    u.permalink,
        CASE
            WHEN is_owner_or_admin(u.id) THEN email_active(u.*)
            ELSE NULL::boolean
        END AS email_active,
    u.public_name,
        CASE
            WHEN ("current_user"() = 'anonymous'::name) THEN false
            ELSE user_following_this_user(current_user_id(), u.id)
        END AS following_this_user,
    (CASE WHEN is_owner_or_admin(u.id) THEN u.state_inscription ELSE null END) state_inscription,
    (CASE WHEN is_owner_or_admin(u.id) THEN u.birth_date ELSE null END) birth_date,
    (CASE WHEN is_owner_or_admin(u.id) THEN u.account_type ELSE null END) account_type,
    ("current_user"() = 'admin'::name) AS is_admin_role
   FROM (users u
     LEFT JOIN "1".user_totals ut ON ((ut.user_id = u.id)));

}
  end
end
