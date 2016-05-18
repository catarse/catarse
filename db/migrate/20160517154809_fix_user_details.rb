class FixUserDetails < ActiveRecord::Migration
  def change
    execute <<-SQL
    create or replace view "1".user_details as
     SELECT u.id,
    u.name,
    u.address_city,
    u.deactivated_at,
    thumbnail_image(u.*) AS profile_img_thumbnail,
    u.facebook_link,
    u.twitter AS twitter_username,
    (CASE WHEN public.is_owner_or_admin(u.id) THEN u.email ELSE NULL::text END) AS email,
    COALESCE(ut.total_contributed_projects, (0)::bigint) AS total_contributed_projects,
    COALESCE(ut.total_published_projects, (0)::bigint) AS total_published_projects,
    ( SELECT json_agg(DISTINCT ul.link) AS json_agg
           FROM user_links ul
          WHERE (ul.user_id = u.id)) AS links
   FROM (users u
     LEFT JOIN "1".user_totals ut ON ((ut.user_id = u.id)));
    SQL
  end
end
