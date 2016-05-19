class FixesSomeAccess < ActiveRecord::Migration
  def change
    execute %Q{
REVOKE SELECT ON "1".direct_messages FROM anonymous, web_user; 
REVOKE SELECT ON "1".user_totals FROM anonymous, web_user; 

CREATE OR REPLACE VIEW "1"."user_details" AS 
 SELECT u.id,
    u.name,
    u.address_city,
    u.deactivated_at,
    thumbnail_image(u.*) AS profile_img_thumbnail,
    u.facebook_link,
    u.twitter AS twitter_username,
    null::text as email,
    COALESCE(ut.total_contributed_projects, (0)::bigint) AS total_contributed_projects,
    COALESCE(ut.total_published_projects, (0)::bigint) AS total_published_projects,
    ( SELECT json_agg(DISTINCT ul.link) AS json_agg
           FROM user_links ul
          WHERE (ul.user_id = u.id)) AS links
   FROM (users u
     LEFT JOIN "1".user_totals ut ON ((ut.user_id = u.id)));
    }
  end
end
