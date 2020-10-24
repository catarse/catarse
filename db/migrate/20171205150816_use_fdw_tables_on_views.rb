class UseFdwTablesOnViews < ActiveRecord::Migration[4.2]
  # WARNING - before running this migration you will need to generate FDW tables by running `rake common:generate_fdw` (don't forget to set appropriate settings first)
  def change
    if Rails.env.test?
      # circleci specific
      # this is needed to create a fake external db for use with fdw
      execute <<-SQL
      create schema common_schema;
      DROP SCHEMA IF EXISTS payment_service CASCADE;
      CREATE SCHEMA payment_service;

      CREATE TYPE payment_service.payment_status AS ENUM (
          'pending',
          'paid',
          'refused',
          'refunded',
          'chargedback',
          'deleted',
          'error'
      );

      CREATE TYPE payment_service.subscription_status AS ENUM (
          'started',
          'active',
          'inactive',
          'canceled',
          'deleted',
          'error'
      );

CREATE TABLE common_schema.subscriptions (
    id uuid NOT NULL,
    platform_id uuid NOT NULL,
    project_id uuid NOT NULL,
    user_id uuid NOT NULL,
    reward_id uuid,
    credit_card_id uuid,
    status payment_service.subscription_status NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    checkout_data jsonb NOT NULL
);
CREATE TABLE common_schema.catalog_payments (
    id uuid NOT NULL,
    platform_id uuid NOT NULL,
    project_id uuid NOT NULL,
    user_id uuid NOT NULL,
    subscription_id uuid,
    reward_id uuid,
    data jsonb NOT NULL,
    gateway text NOT NULL,
    gateway_cached_data jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    common_contract_data jsonb NOT NULL,
    gateway_general_data jsonb NOT NULL,
    status payment_service.payment_status NOT NULL,
    external_id text,
    error_retry_at timestamp without time zone
);
CREATE TABLE common_schema.payment_status_transitions (
    id uuid NOT NULL,
    catalog_payment_id uuid NOT NULL,
    from_status payment_service.payment_status NOT NULL,
    to_status payment_service.payment_status NOT NULL,
    data jsonb NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE common_schema.antifraud_analyses (
  id uuid NOT NULL,
  catalog_payment_id uuid NOT NULL,
  cost numeric NOT NULL,
  data jsonb NOT NULL,
  created_at timestamp without time zone NOT NULL,
  updated_at timestamp without time zone NOT NULL
);

      SQL
    end
    execute <<-SQL
    CREATE OR REPLACE FUNCTION paid_count(rewards) RETURNS bigint AS $$
    SELECT case when (SELECT p.mode from projects p join rewards r on r.project_id = p.id where r.id = $1.id) = 'sub' THEN
 (SELECT count(*)
                           FROM common_schema.subscriptions s
                           where s.status = 'active'
                             AND s.reward_id = $1.common_id)
    else
 (SELECT count(*)
                           FROM payments p
                           JOIN contributions c ON c.id = p.contribution_id
                           JOIN projects prj ON c.project_id = prj.id
                           WHERE (CASE WHEN prj.state = 'failed' THEN p.state IN ('refunded', 'pending_refund', 'paid') ELSE p.state = 'paid' END)
                             AND c.reward_id = $1.id)
                             END
    $$ LANGUAGE SQL STABLE SECURITY DEFINER;


    CREATE OR REPLACE FUNCTION waiting_payment_count(rewards) RETURNS bigint AS $$
    SELECT case when (SELECT p.mode from projects p join rewards r on r.project_id = p.id where r.id = $1.id) = 'sub' THEN
    (
      SELECT count(*)
      FROM common_schema.subscriptions s
      WHERE s.status = 'started' and s.reward_id = $1.common_id
      )
    ELSE
    (
      SELECT count(*)
      FROM payments p join contributions c on c.id = p.contribution_id
      WHERE p.waiting_payment AND c.reward_id = $1.id
      )
      END
    $$ LANGUAGE SQL STABLE SECURITY DEFINER;











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
            sum((sp.data->>'amount')::numeric)/100 AS sum,
            count(DISTINCT s.id) AS count
           FROM common_schema.subscriptions s
           LEFT JOIN common_schema.catalog_payments sp on sp.subscription_id = s.id
          WHERE s.status IN ('active', 'inactive', 'canceled')
          and sp.status = 'paid'
          GROUP BY s.user_id) subs ON u.common_id = subs.user_id ;

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











CREATE OR REPLACE VIEW "1"."projects" AS
 SELECT p.id AS project_id,
    p.category_id,
    p.name AS project_name,
    p.headline,
    p.permalink,
    p.mode,
    (p.state)::text AS state,
    so.so AS state_order,
    od.od AS online_date,
    p.recommended,
    thumbnail_image(p.*, 'large'::text) AS project_img,
    remaining_time_json(p.*) AS remaining_time,
    p.expires_at,
    COALESCE(( SELECT
                CASE
                    WHEN (p.mode = 'sub'::text) THEN ( SELECT sum((s_1.checkout_data->>'amount')::numeric / 100) AS sum
                       FROM common_schema.subscriptions s_1
                      WHERE ((s_1.project_id = p.common_id) AND ((s_1.status)::text = 'active'::text)))
                    ELSE ( SELECT
                            CASE
                                WHEN ((p.state)::text = 'failed'::text) THEN pt.pledged
                                ELSE pt.paid_pledged
                            END AS paid_pledged
                       FROM "1".project_totals pt
                      WHERE (pt.project_id = p.id))
                END AS paid_pledged), (0)::numeric) AS pledged,
    COALESCE(( SELECT
                CASE
                    WHEN (p.mode = 'sub'::text) THEN ((( SELECT sum((s_1.checkout_data->>'amount')::numeric / 100) AS sum
                       FROM common_schema.subscriptions s_1
                      WHERE ((s_1.project_id = p.common_id) AND ((s_1.status)::text = 'active'::text))) / COALESCE(( SELECT g.value
                       FROM goals g
                      WHERE ((g.project_id = p.id) AND (g.value >= ( SELECT sum((s_1.checkout_data->>'amount')::numeric / 100) AS sum
                               FROM common_schema.subscriptions s_1
                              WHERE ((s_1.project_id = p.common_id) AND ((s_1.status)::text = 'active'::text))))) limit 1), ( SELECT max(goals.value) AS max
                       FROM goals
                      WHERE (goals.project_id = p.id)))) * (100)::numeric)
                    ELSE ( SELECT pt.progress
                       FROM "1".project_totals pt
                      WHERE (pt.project_id = p.id))
                END AS progress), (0)::numeric) AS progress,
    s.acronym AS state_acronym,
    u.name AS owner_name,
    c.name AS city_name,
    p.full_text_index,
    is_current_and_online(p.expires_at, (p.state)::text) AS open_for_contributions,
    elapsed_time_json(p.*) AS elapsed_time,
    score(p.*) AS score,
    (EXISTS ( SELECT true AS bool
           FROM (contributions c_1
             JOIN user_follows uf ON ((uf.follow_id = c_1.user_id)))
          WHERE ((is_confirmed(c_1.*) AND (uf.user_id = current_user_id())) AND (c_1.project_id = p.id)))) AS contributed_by_friends,
    p.user_id AS project_user_id,
    p.video_embed_url,
    p.updated_at,
    u.public_name AS owner_public_name,
    zone_timestamp(p.expires_at) AS zone_expires_at
   FROM (((((projects p
     JOIN users u ON ((p.user_id = u.id)))
     LEFT JOIN cities c ON ((c.id = p.city_id)))
     LEFT JOIN states s ON ((s.id = c.state_id)))
     JOIN LATERAL zone_timestamp(online_at(p.*)) od(od) ON (true))
     JOIN LATERAL state_order(p.*) so(so) ON (true));

    SQL
  end
end
