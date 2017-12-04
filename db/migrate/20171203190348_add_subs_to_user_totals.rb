class AddSubsToUserTotals < ActiveRecord::Migration
  def change
    execute <<-SQL

  drop view "1".team_members;
  drop view "1".user_followers;
  drop view "1".user_follows;
  drop view "1".user_friends;
  drop view "1".creator_suggestions;
  drop view "1".contributors ;
  drop view "1".user_details ;
  drop view "1".project_contributions;
  drop  materialized view "1".user_totals;
  create  materialized view "1".user_totals as
   SELECT u.id,
    u.id AS user_id,
    COALESCE(subs.total_contributed_projects, 0::bigint) + COALESCE(ct.total_contributed_projects, 0::bigint) AS total_contributed_projects,
    COALESCE(subs.sum, 0::numeric)  + COALESCE(ct.sum, 0::numeric) AS sum,
    COALESCE(subs.count, 0::bigint) + COALESCE(ct.count, 0::bigint) AS count,
    COALESCE(( SELECT count(*) AS count
           FROM projects p2
          WHERE is_published(p2.*) AND p2.user_id = u.id), 0::bigint) AS total_published_projects
   FROM users u
     LEFT JOIN ( SELECT c.user_id,
            count(DISTINCT c.project_id) AS total_contributed_projects,
            sum(pa.value) AS sum,
            count(DISTINCT c.id) AS count
           FROM contributions c
             JOIN payments pa ON c.id = pa.contribution_id
             JOIN projects p ON c.project_id = p.id
          WHERE pa.state = ANY (confirmed_states())
          GROUP BY c.user_id) ct ON u.id = ct.user_id
     LEFT JOIN ( SELECT s.user_id,
            count(DISTINCT s.project_id) AS total_contributed_projects,
            sum((sp.gateway_data->>'amount')::numeric)/100 AS sum,
            count(DISTINCT s.id) AS count
           FROM subscriptions s
           LEFT JOIN subscription_payments sp on sp.subscription_id = s.id
          WHERE s.status IN ('active', 'inactive', 'canceled')
          and sp.status = 'paid'
          GROUP BY s.user_id) subs ON u.id = subs.user_id ;

CREATE UNIQUE INDEX user_totals_uidx ON "1".user_totals (id);


          create view "1".team_members as
 SELECT u.id,
    u.name,
    thumbnail_image(u.*) AS img,
    COALESCE(ut.total_contributed_projects, 0::bigint) AS total_contributed_projects,
    COALESCE(ut.sum, 0::numeric) AS total_amount_contributed
   FROM users u
     LEFT JOIN "1".user_totals ut ON ut.user_id = u.id
  WHERE u.admin
  ORDER BY u.name;
  grant select on "1".team_members to admin, anonymous, web_user;



  create view "1".user_followers as
 SELECT uf.user_id,
    uf.follow_id,
    json_build_object('name', f.name, 'pulic_name', f.public_name, 'avatar', thumbnail_image(f.*), 'total_contributed_projects', ut.total_contributed_projects, 'total_published_projects', ut.total_published_projects, 'city', add.address_city, 'state', st.acronym, 'following', user_following_this_user(uf.follow_id, uf.user_id)) AS source,
    zone_timestamp(uf.created_at) AS created_at,
    user_following_this_user(uf.follow_id, uf.user_id) AS following
   FROM user_follows uf
     LEFT JOIN "1".user_totals ut ON ut.user_id = uf.user_id
     JOIN users f ON f.id = uf.user_id
     LEFT JOIN addresses add ON f.address_id = add.id
     LEFT JOIN states st ON st.id = add.state_id
  WHERE is_owner_or_admin(uf.follow_id) AND f.deactivated_at IS NULL AND uf.follow_id IS NOT NULL;

GRANT SELECT, INSERT, DELETE ON "1".user_followers TO admin, web_user;

  create view "1".user_follows as
SELECT uf.user_id,
    uf.follow_id,
    json_build_object('public_name', f.public_name, 'name', f.name, 'avatar', thumbnail_image(f.*), 'total_contributed_projects', ut.total_contributed_projects, 'total_published_projects', ut.total_published_projects, 'city', add.address_city, 'state', st.acronym) AS source,
    zone_timestamp(uf.created_at) AS created_at
   FROM user_follows uf
     LEFT JOIN "1".user_totals ut ON ut.user_id = uf.follow_id
     JOIN users f ON f.id = uf.follow_id
     LEFT JOIN addresses add ON f.address_id = add.id
     LEFT JOIN states st ON st.id = add.state_id
  WHERE is_owner_or_admin(uf.user_id) AND f.deactivated_at IS NULL;


CREATE TRIGGER insert_user_follow INSTEAD OF INSERT ON "1".user_follows 
FOR EACH ROW EXECUTE PROCEDURE public.insert_user_follow();

CREATE TRIGGER delete_user_follow INSTEAD OF DELETE ON "1".user_follows 
FOR EACH ROW EXECUTE PROCEDURE public.delete_user_follow();

GRANT SELECT, INSERT, DELETE ON "1".user_follows TO admin, web_user;
GRANT SELECT, INSERT, DELETE ON public.user_follows TO admin, web_user;
GRANT USAGE ON SEQUENCE user_follows_id_seq TO admin, web_user;


  create view "1".user_friends as
SELECT uf.user_id,
    uf.friend_id,
    user_following_this_user(uf.user_id, uf.friend_id) AS following,
    f.name,
    thumbnail_image(f.*) AS avatar,
    ut.total_contributed_projects,
    ut.total_published_projects,
    add.address_city AS city,
    st.acronym::text AS state,
    f.public_name
   FROM user_friends uf
     LEFT JOIN "1".user_totals ut ON ut.user_id = uf.friend_id
     JOIN users f ON f.id = uf.friend_id
     LEFT JOIN addresses add ON f.address_id = add.id
     LEFT JOIN states st ON st.id = add.state_id
  WHERE is_owner_or_admin(uf.user_id) AND f.deactivated_at IS NULL;
GRANT SELECT ON "1".user_friends TO admin, web_user;


  create view "1".creator_suggestions as
 SELECT u.id,
    u.id AS user_id,
    thumbnail_image(u.*) AS avatar,
    u.name,
    add.address_city AS city,
    st.acronym::text AS state,
    ut.total_contributed_projects,
    ut.total_published_projects,
    zone_timestamp(u.created_at) AS created_at,
    user_following_this_user(current_user_id(), u.id) AS following,
    u.public_name
   FROM contributions c
     JOIN projects p ON p.id = c.project_id
     JOIN users u ON u.id = p.user_id
     LEFT JOIN addresses add ON add.id = u.address_id
     LEFT JOIN states st ON st.id = add.state_id
     JOIN "1".user_totals ut ON ut.user_id = u.id
  WHERE was_confirmed(c.*) AND u.id <> current_user_id() AND c.user_id = current_user_id() AND u.deactivated_at IS NULL
  GROUP BY u.id, ut.total_contributed_projects, ut.total_published_projects, add.address_city, st.acronym;

grant select on "1".creator_suggestions to admin, web_user;


  create view "1".contributors as
SELECT u.id,
    u.id AS user_id,
    c.project_id,
    json_build_object('profile_img_thumbnail', thumbnail_image(u.*), 'public_name', u.public_name, 'name', u.name, 'city', add.address_city, 'state', st.acronym, 'total_contributed_projects', ut.total_contributed_projects, 'total_published_projects', ut.total_published_projects) AS data,
    (EXISTS ( SELECT true AS bool
           FROM user_follows uf
          WHERE uf.user_id = current_user_id() AND uf.follow_id = u.id)) AS is_follow
   FROM contributions c
     JOIN users u ON u.id = c.user_id
     LEFT JOIN addresses add ON add.id = u.address_id
     LEFT JOIN states st ON st.id = add.state_id
     JOIN projects p ON p.id = c.project_id
     JOIN "1".user_totals ut ON ut.user_id = u.id
  WHERE
        CASE
            WHEN p.state::text = ANY (ARRAY['failed'::text, 'rejected'::text]) THEN was_confirmed(c.*)
            ELSE is_confirmed(c.*)
        END AND NOT c.anonymous AND u.deactivated_at IS NULL
  GROUP BY u.id, c.project_id, ut.total_contributed_projects, ut.total_published_projects, add.address_city, st.acronym;


GRANT SELECT ON "1".contributors TO admin, anonymous, web_user;


  create view "1".user_details as
SELECT u.id,
    u.common_id,
        CASE
            WHEN u.deactivated_at IS NOT NULL AND NOT is_owner_or_admin(u.id) THEN ''::character varying(255)::text
            ELSE u.name
        END AS name,
    u.deactivated_at,
    thumbnail_image(u.*) AS profile_img_thumbnail,
        CASE
            WHEN u.deactivated_at IS NOT NULL AND NOT is_owner_or_admin(u.id) THEN ''::character varying(255)
            ELSE u.facebook_link
        END AS facebook_link,
        CASE
            WHEN u.deactivated_at IS NOT NULL AND NOT is_owner_or_admin(u.id) THEN ''::character varying(255)
            ELSE u.twitter
        END AS twitter_username,
        CASE
            WHEN is_owner_or_admin(u.id) THEN row_to_json(add.*)
            ELSE NULL::json
        END AS address,
        CASE
            WHEN is_owner_or_admin(u.id) THEN u.email
            ELSE NULL::text
        END AS email,
    COALESCE(ut.total_contributed_projects, 0::bigint) AS total_contributed_projects,
    COALESCE(ut.total_published_projects, 0::bigint) AS total_published_projects,
    ( SELECT json_agg(links.*) AS json_agg
           FROM ( SELECT ul.id,
                    ul.link
                   FROM user_links ul
                  WHERE ul.user_id = u.id) links) AS links,
    ( SELECT count(*) AS count
           FROM user_follows uf
          WHERE uf.user_id = u.id) AS follows_count,
    ( SELECT count(*) AS count
           FROM user_follows uf
          WHERE uf.follow_id = u.id) AS followers_count,
        CASE
            WHEN is_owner_or_admin(u.id) THEN u.cpf
            ELSE NULL::text
        END AS owner_document,
    cover_image_url(u.*) AS profile_cover_image,
    u.created_at,
        CASE
            WHEN u.deactivated_at IS NOT NULL AND NOT is_owner_or_admin(u.id) THEN NULL::text
            ELSE u.about_html
        END AS about_html,
    is_owner_or_admin(u.id) AS is_owner_or_admin,
        CASE
            WHEN u.deactivated_at IS NOT NULL AND NOT is_owner_or_admin(u.id) THEN false
            ELSE u.newsletter
        END AS newsletter,
        CASE
            WHEN u.deactivated_at IS NOT NULL AND NOT is_owner_or_admin(u.id) THEN false
            ELSE u.subscribed_to_project_posts
        END AS subscribed_to_project_posts,
        CASE
            WHEN u.deactivated_at IS NOT NULL AND NOT is_owner_or_admin(u.id) THEN false
            ELSE u.subscribed_to_new_followers
        END AS subscribed_to_new_followers,
        CASE
            WHEN u.deactivated_at IS NOT NULL AND NOT is_owner_or_admin(u.id) THEN false
            ELSE u.subscribed_to_friends_contributions
        END AS subscribed_to_friends_contributions,
    "current_user"() = 'admin'::name AS is_admin,
    u.permalink,
        CASE
            WHEN is_owner_or_admin(u.id) THEN email_active(u.*)
            ELSE NULL::boolean
        END AS email_active,
    u.public_name,
        CASE
            WHEN "current_user"() = 'anonymous'::name THEN false
            ELSE user_following_this_user(current_user_id(), u.id)
        END AS following_this_user,
        CASE
            WHEN is_owner_or_admin(u.id) THEN u.state_inscription
            ELSE NULL::character varying
        END AS state_inscription,
        CASE
            WHEN is_owner_or_admin(u.id) THEN u.birth_date
            ELSE NULL::date
        END AS birth_date,
        CASE
            WHEN is_owner_or_admin(u.id) THEN u.account_type
            ELSE NULL::text
        END AS account_type,
    "current_user"() = 'admin'::name AS is_admin_role,
        CASE
            WHEN is_owner_or_admin(u.id) THEN json_agg(json_build_object('user_marketing_list_id', mmu.id, 'marketing_list', row_to_json(mml.*)))
            ELSE NULL::json
        END AS mail_marketing_lists
   FROM users u
     LEFT JOIN "1".user_totals ut ON ut.user_id = u.id
     LEFT JOIN addresses add ON add.id = u.address_id
     LEFT JOIN mail_marketing_users mmu ON mmu.user_id = u.id
     LEFT JOIN mail_marketing_lists mml ON mml.id = mmu.mail_marketing_list_id
  GROUP BY u.id, add.*, ut.total_contributed_projects, ut.total_published_projects;

grant select on "1".user_details to admin, web_user, anonymous;



  create view "1".project_contributions as
 SELECT c.anonymous,
    c.project_id,
    c.reward_id::numeric AS reward_id,
    c.id::numeric AS id,
    thumbnail_image(u.*) AS profile_img_thumbnail,
    u.id AS user_id,
    u.name AS user_name,
    c.value,
    pa.state,
    u.email,
    row_to_json(r.*)::jsonb AS reward,
    waiting_payment(pa.*) AS waiting_payment,
    is_owner_or_admin(p.user_id) AS is_owner_or_admin,
    ut.total_contributed_projects,
    zone_timestamp(c.created_at) AS created_at,
    NULL::boolean AS has_another,
    pa.full_text_index,
    c.delivery_status,
    u.created_at AS user_created_at,
    ut.total_published_projects,
    pa.payment_method,
    c.survey_answered_at,
    s.sent_at,
    s.finished_at,
    COALESCE(
        CASE
            WHEN c.survey_answered_at IS NOT NULL THEN 'answered'::text
            WHEN s.sent_at IS NOT NULL THEN 'sent'::text
            WHEN s.sent_at IS NULL THEN 'not_sent'::text
            ELSE NULL::text
        END, ''::text) AS survey_status,
    u.public_name AS public_user_name
   FROM contributions c
     JOIN users u ON c.user_id = u.id
     JOIN projects p ON p.id = c.project_id
     JOIN payments pa ON pa.contribution_id = c.id
     LEFT JOIN "1".user_totals ut ON ut.id = u.id
     LEFT JOIN rewards r ON r.id = c.reward_id
     LEFT JOIN surveys s ON s.reward_id = c.reward_id
  WHERE (was_confirmed(c.*) AND pa.state <> 'pending'::text OR waiting_payment(pa.*)) AND is_owner_or_admin(p.user_id) OR c.user_id = current_user_id();
GRANT SELECT ON "1".project_contributions TO anonymous, web_user, admin;

    SQL
  end
end
