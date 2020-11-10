class AddOtimizationsQueriesAfterOrdemProject < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE OR REPLACE VIEW "1"."user_details" AS
 SELECT u.id,
    u.common_id,
        CASE
            WHEN ((u.deactivated_at IS NOT NULL) AND (NOT is_owner_or_admin(u.id))) THEN (''::character varying(255))::text
            ELSE u.name
        END AS name,
    u.deactivated_at,
    thumbnail_image(u.*) AS profile_img_thumbnail,
        CASE
            WHEN ((u.deactivated_at IS NOT NULL) AND (NOT is_owner_or_admin(u.id))) THEN ''::character varying(255)
            ELSE u.facebook_link
        END AS facebook_link,
        CASE
            WHEN ((u.deactivated_at IS NOT NULL) AND (NOT is_owner_or_admin(u.id))) THEN ''::character varying(255)
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
            WHEN is_owner_or_admin(u.id) THEN u.cpf
            ELSE NULL::text
        END AS owner_document,
    cover_image_url(u.*) AS profile_cover_image,
    u.created_at,
        CASE
            WHEN ((u.deactivated_at IS NOT NULL) AND (NOT is_owner_or_admin(u.id))) THEN NULL::text
            ELSE u.about_html
        END AS about_html,
    is_owner_or_admin(u.id) AS is_owner_or_admin,
        CASE
            WHEN ((u.deactivated_at IS NOT NULL) AND (NOT is_owner_or_admin(u.id))) THEN false
            ELSE u.newsletter
        END AS newsletter,
        CASE
            WHEN ((u.deactivated_at IS NOT NULL) AND (NOT is_owner_or_admin(u.id))) THEN false
            ELSE u.subscribed_to_project_posts
        END AS subscribed_to_project_posts,
        CASE
            WHEN ((u.deactivated_at IS NOT NULL) AND (NOT is_owner_or_admin(u.id))) THEN false
            ELSE u.subscribed_to_new_followers
        END AS subscribed_to_new_followers,
        CASE
            WHEN ((u.deactivated_at IS NOT NULL) AND (NOT is_owner_or_admin(u.id))) THEN false
            ELSE u.subscribed_to_friends_contributions
        END AS subscribed_to_friends_contributions,
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
    ("current_user"() = 'admin'::name) AS is_admin_role,
        CASE
            WHEN is_owner_or_admin(u.id) THEN json_agg(json_build_object('user_marketing_list_id', mmu.id, 'marketing_list', row_to_json(mml.*)))
            ELSE NULL::json
        END AS mail_marketing_lists
   FROM ((((users u
     LEFT JOIN "1".user_totals ut ON ((ut.id= u.id)))
     LEFT JOIN addresses add ON ((add.id = u.address_id)))
     LEFT JOIN mail_marketing_users mmu ON ((mmu.user_id = u.id)))
     LEFT JOIN mail_marketing_lists mml ON ((mml.id = mmu.mail_marketing_list_id)))
  GROUP BY u.id, add.*, ut.total_contributed_projects, ut.total_published_projects;

CREATE OR REPLACE VIEW "1"."categories" AS
    SELECT c.id,
    c.name_pt AS name,
    0::bigint as online_projects,
    0::bigint as followers,
    false as following
   FROM
   categories c;

CREATE OR REPLACE VIEW "1"."reward_details" AS
 SELECT r.id,
    r.project_id,
    r.description,
    r.minimum_value,
    r.maximum_contributions,
    r.deliver_at,
    r.updated_at,
    COALESCE(((rms.data ->> 'paid_count'::text))::bigint, (0)::bigint) AS paid_count,
    COALESCE(((rms.data ->> 'waiting_payment_count'::text))::bigint, (0)::bigint) AS waiting_payment_count,
    r.shipping_options,
    r.row_order,
    r.title,
    s.sent_at AS survey_sent_at,
    s.finished_at AS survey_finished_at,
    r.common_id,
        CASE
            WHEN is_owner_or_admin(p.user_id) THEN r.welcome_message_subject
            ELSE ''::text
        END AS welcome_message_subject,
        CASE
            WHEN is_owner_or_admin(p.user_id) THEN r.welcome_message_body
            ELSE ''::text
        END AS welcome_message_body,
    thumbnail_image(r.*) AS uploaded_image,
    r.run_out
   FROM rewards r
     JOIN projects p on p.id = r.project_id
     LEFT JOIN reward_metric_storages rms ON ((rms.reward_id = r.id))
     LEFT JOIN surveys s ON ((s.reward_id = r.id));


CREATE OR REPLACE VIEW "1"."project_details" AS
 SELECT p.id AS project_id,
    p.id,
    p.user_id,
    p.name,
    p.headline,
    p.budget,
    p.goal,
    p.about_html,
    p.permalink,
    p.video_embed_url,
    p.video_url,
    c.name_pt AS category_name,
    c.id AS category_id,
    original_image(p.*) AS original_image,
    thumbnail_image(p.*, 'thumb'::text) AS thumb_image,
    thumbnail_image(p.*, 'small'::text) AS small_image,
    thumbnail_image(p.*, 'large'::text) AS large_image,
    thumbnail_image(p.*, 'video_cover'::text) AS video_cover_image,
    COALESCE((pt.data->>'progress')::numeric, (0)::numeric) AS progress,
    COALESCE(
        CASE
            WHEN ((p.state)::text = ANY (ARRAY[('failed'::character varying)::text, ('rejected'::character varying)::text])) THEN (pt.data->>'pledged')::numeric
            ELSE (pt.data->>'pledged')::numeric
        END, (0)::numeric) AS pledged,
    COALESCE((pt.data->>'total_contributions')::bigint, (0)::bigint) AS total_contributions,
    COALESCE((pt.data->>'total_contributors')::bigint, (0)::bigint) AS total_contributors,
    (p.state)::text AS state,
    p.mode,
    state_order(p.*) AS state_order,
    p.expires_at,
    zone_timestamp(p.expires_at) AS zone_expires_at,
    online_at(p.*) AS online_date,
    zone_timestamp(online_at(p.*)) AS zone_online_date,
    zone_timestamp(in_analysis_at(p.*)) AS sent_to_analysis_at,
    is_published(p.*) AS is_published,
    is_expired(p.*) AS is_expired,
    open_for_contributions(p.*) AS open_for_contributions,
    p.online_days,
    remaining_time_json(p.*) AS remaining_time,
    elapsed_time_json(p.*) AS elapsed_time,
    posts_size.count AS posts_count,
    json_build_object('city', ct.name, 'state_acronym', st.acronym, 'state', st.name) AS address,
    json_build_object('id', u.id, 'name', u.name, 'public_name', u.public_name) AS "user",
    ( SELECT count(DISTINCT pr_1.user_id) AS count
           FROM project_reminders pr_1
          WHERE (pr_1.project_id = p.id)) AS reminder_count,
    is_owner_or_admin(p.user_id) AS is_owner_or_admin,
    user_signed_in() AS user_signed_in,
    current_user_already_in_reminder(p.*) AS in_reminder,
    posts_size.count AS total_posts,
    (((p.state)::text = 'successful'::text) AND ((p.expires_at)::date >= '2016-06-06'::date)) AS can_request_transfer,
    ("current_user"() = 'admin'::name) AS is_admin_role,
    (EXISTS ( SELECT true AS bool
           FROM (contributions c_1
             JOIN user_follows uf ON ((uf.follow_id = c_1.user_id)))
          WHERE (is_confirmed(c_1.*) AND (uf.user_id = current_user_id()) AND (c_1.project_id = p.id)))) AS contributed_by_friends,
        CASE
            WHEN ("current_user"() = 'admin'::name) THEN NULLIF(btrim((array_agg(DISTINCT admin_tags_lateral.tag_list))::text, '{}'::text), 'NULL'::text)
            ELSE NULL::text
        END AS admin_tag_list,
    NULLIF(btrim((array_agg(DISTINCT tags_lateral.tag_list))::text, '{}'::text), 'NULL'::text) AS tag_list,
    ct.id AS city_id,
        CASE
            WHEN ("current_user"() = 'admin'::name) THEN p.admin_notes
            ELSE NULL::text
        END AS admin_notes,
    p.service_fee,
    has_cancelation_request(p.*) AS has_cancelation_request,
        CASE
            WHEN is_owner_or_admin(p.user_id) THEN can_cancel(p.*)
            ELSE false
        END AS can_cancel,
    p.tracker_snippet_html,
    cover_image_thumb(p.*) AS cover_image,
    p.common_id,
        CASE
            WHEN (p.content_rating >= 18) THEN true
            ELSE false
        END AS is_adult_content,
    p.content_rating,
    p.recommended,
        CASE
            WHEN (integrations_size.count > 0) THEN ( SELECT json_agg(json_build_object('id', integration.id, 'name', integration.name, 'data', integration.data)) AS json_agg
               FROM project_integrations integration
              WHERE (p.id = integration.project_id))
            ELSE '[]'::json
        END AS integrations
   FROM (((((((((projects p
     JOIN categories c ON ((c.id = p.category_id)))
     JOIN users u ON ((u.id = p.user_id)))
     LEFT JOIN project_metric_storages pt ON ((pt.project_id = p.id)))
     LEFT JOIN cities ct ON ((ct.id = p.city_id)))
     LEFT JOIN states st ON ((st.id = ct.state_id)))
     LEFT JOIN LATERAL ( SELECT count(1) AS count
           FROM project_integrations pi
          WHERE (pi.project_id = p.id)) integrations_size ON (true))
     LEFT JOIN LATERAL ( SELECT count(1) AS count
           FROM project_posts pp
          WHERE (pp.project_id = p.id)) posts_size ON (true))
     LEFT JOIN LATERAL ( SELECT t1.name AS tag_list
           FROM (taggings tgs
             JOIN tags t1 ON ((t1.id = tgs.tag_id)))
          WHERE ((tgs.project_id = p.id) AND (tgs.tag_id IS NOT NULL))) admin_tags_lateral ON (true))
     LEFT JOIN LATERAL ( SELECT pt1.name AS tag_list
           FROM (taggings tgs
             JOIN public_tags pt1 ON ((pt1.id = tgs.public_tag_id)))
          WHERE ((tgs.project_id = p.id) AND (tgs.public_tag_id IS NOT NULL))) tags_lateral ON (true))
  GROUP BY posts_size.count, integrations_size.count, ct.id, p.id, c.id, u.id, c.name_pt, ct.name, st.acronym, st.name, (pt.data->>'progress')::numeric, (pt.data->>'pledged')::numeric, (pt.data->>'paid_pledged')::numeric, (pt.data->>'total_contributions')::bigint, p.state, p.expires_at, (pt.data->>'total_contributors')::bigint;
    SQL
  end

  def down
    execute <<-SQL
CREATE OR REPLACE VIEW "1"."project_details" AS
 SELECT p.id AS project_id,
    p.id,
    p.user_id,
    p.name,
    p.headline,
    p.budget,
    p.goal,
    p.about_html,
    p.permalink,
    p.video_embed_url,
    p.video_url,
    c.name_pt AS category_name,
    c.id AS category_id,
    original_image(p.*) AS original_image,
    thumbnail_image(p.*, 'thumb'::text) AS thumb_image,
    thumbnail_image(p.*, 'small'::text) AS small_image,
    thumbnail_image(p.*, 'large'::text) AS large_image,
    thumbnail_image(p.*, 'video_cover'::text) AS video_cover_image,
    COALESCE(pt.progress, (0)::numeric) AS progress,
    COALESCE(
        CASE
            WHEN ((p.state)::text = ANY (ARRAY[('failed'::character varying)::text, ('rejected'::character varying)::text])) THEN pt.pledged
            ELSE pt.paid_pledged
        END, (0)::numeric) AS pledged,
    COALESCE(pt.total_contributions, (0)::bigint) AS total_contributions,
    COALESCE(pt.total_contributors, (0)::bigint) AS total_contributors,
    (p.state)::text AS state,
    p.mode,
    state_order(p.*) AS state_order,
    p.expires_at,
    zone_timestamp(p.expires_at) AS zone_expires_at,
    online_at(p.*) AS online_date,
    zone_timestamp(online_at(p.*)) AS zone_online_date,
    zone_timestamp(in_analysis_at(p.*)) AS sent_to_analysis_at,
    is_published(p.*) AS is_published,
    is_expired(p.*) AS is_expired,
    open_for_contributions(p.*) AS open_for_contributions,
    p.online_days,
    remaining_time_json(p.*) AS remaining_time,
    elapsed_time_json(p.*) AS elapsed_time,
    posts_size.count AS posts_count,
    json_build_object('city', ct.name, 'state_acronym', st.acronym, 'state', st.name) AS address,
    json_build_object('id', u.id, 'name', u.name, 'public_name', u.public_name) AS "user",
    ( SELECT count(DISTINCT pr_1.user_id) AS count
          FROM project_reminders pr_1
          WHERE (pr_1.project_id = p.id)) AS reminder_count,
    is_owner_or_admin(p.user_id) AS is_owner_or_admin,
    user_signed_in() AS user_signed_in,
    current_user_already_in_reminder(p.*) AS in_reminder,
    posts_size.count AS total_posts,
    (((p.state)::text = 'successful'::text) AND ((p.expires_at)::date >= '2016-06-06'::date)) AS can_request_transfer,
    ("current_user"() = 'admin'::name) AS is_admin_role,
    (EXISTS ( SELECT true AS bool
          FROM (contributions c_1
             JOIN user_follows uf ON ((uf.follow_id = c_1.user_id)))
          WHERE (is_confirmed(c_1.*) AND (uf.user_id = current_user_id()) AND (c_1.project_id = p.id)))) AS contributed_by_friends,
        CASE
            WHEN ("current_user"() = 'admin'::name) THEN NULLIF(btrim((array_agg(DISTINCT admin_tags_lateral.tag_list))::text, '{}'::text), 'NULL'::text)
            ELSE NULL::text
        END AS admin_tag_list,
    NULLIF(btrim((array_agg(DISTINCT tags_lateral.tag_list))::text, '{}'::text), 'NULL'::text) AS tag_list,
    ct.id AS city_id,
        CASE
            WHEN ("current_user"() = 'admin'::name) THEN p.admin_notes
            ELSE NULL::text
        END AS admin_notes,
    p.service_fee,
    has_cancelation_request(p.*) AS has_cancelation_request,
        CASE
            WHEN is_owner_or_admin(p.user_id) THEN can_cancel(p.*)
            ELSE false
        END AS can_cancel,
    p.tracker_snippet_html,
    cover_image_thumb(p.*) AS cover_image,
    p.common_id,
        CASE
            WHEN (p.content_rating >= 18) THEN true
            ELSE false
        END AS is_adult_content,
    p.content_rating,
    p.recommended,
        CASE
            WHEN (integrations_size.count > 0) THEN ( SELECT json_agg(json_build_object('id', integration.id, 'name', integration.name, 'data', integration.data)) AS json_agg
              FROM project_integrations integration
              WHERE (p.id = integration.project_id))
            ELSE '[]'::json
        END AS integrations
  FROM (((((((((projects p
     JOIN categories c ON ((c.id = p.category_id)))
     JOIN users u ON ((u.id = p.user_id)))
     LEFT JOIN project_totals pt ON ((pt.project_id = p.id)))
     LEFT JOIN cities ct ON ((ct.id = p.city_id)))
     LEFT JOIN states st ON ((st.id = ct.state_id)))
     LEFT JOIN LATERAL ( SELECT count(1) AS count
          FROM project_integrations pi
          WHERE (pi.project_id = p.id)) integrations_size ON (true))
     LEFT JOIN LATERAL ( SELECT count(1) AS count
          FROM project_posts pp
          WHERE (pp.project_id = p.id)) posts_size ON (true))
     LEFT JOIN LATERAL ( SELECT t1.name AS tag_list
          FROM (taggings tgs
             JOIN tags t1 ON ((t1.id = tgs.tag_id)))
          WHERE ((tgs.project_id = p.id) AND (tgs.tag_id IS NOT NULL))) admin_tags_lateral ON (true))
     LEFT JOIN LATERAL ( SELECT pt1.name AS tag_list
          FROM (taggings tgs
             JOIN public_tags pt1 ON ((pt1.id = tgs.public_tag_id)))
          WHERE ((tgs.project_id = p.id) AND (tgs.public_tag_id IS NOT NULL))) tags_lateral ON (true))
  GROUP BY posts_size.count, integrations_size.count, ct.id, p.id, c.id, u.id, c.name_pt, ct.name, st.acronym, st.name, pt.progress, pt.pledged, pt.paid_pledged, pt.total_contributions, p.state, p.expires_at, pt.total_payment_service_fee, pt.total_contributors;

CREATE OR REPLACE VIEW "1"."categories" AS
 SELECT c.id,
    c.name_pt AS name,
    count(DISTINCT p.id) FILTER (WHERE is_current_and_online(p.expires_at, (p.state)::text)) AS online_projects,
    ( SELECT count(DISTINCT cf.user_id) AS count
          FROM category_followers cf
          WHERE (cf.category_id = c.id)) AS followers,
    (EXISTS ( SELECT true AS bool
          FROM category_followers cf
          WHERE ((cf.category_id = c.id) AND (cf.user_id = current_user_id())))) AS following
  FROM (categories c
     LEFT JOIN projects p ON ((p.category_id = c.id)))
  GROUP BY c.id;

CREATE OR REPLACE VIEW "1"."reward_details" AS
 SELECT r.id,
    r.project_id,
    r.description,
    r.minimum_value,
    r.maximum_contributions,
    r.deliver_at,
    r.updated_at,
    COALESCE(((rms.data ->> 'paid_count'::text))::bigint, (0)::bigint) AS paid_count,
    COALESCE(((rms.data ->> 'waiting_payment_count'::text))::bigint, (0)::bigint) AS waiting_payment_count,
    r.shipping_options,
    r.row_order,
    r.title,
    s.sent_at AS survey_sent_at,
    s.finished_at AS survey_finished_at,
    r.common_id,
        CASE
            WHEN is_owner_or_admin(( SELECT p.user_id
              FROM projects p
              WHERE (p.id = r.project_id))) THEN r.welcome_message_subject
            ELSE ''::text
        END AS welcome_message_subject,
        CASE
            WHEN is_owner_or_admin(( SELECT p.user_id
              FROM projects p
              WHERE (p.id = r.project_id))) THEN r.welcome_message_body
            ELSE ''::text
        END AS welcome_message_body,
    thumbnail_image(r.*) AS uploaded_image,
    r.run_out
  FROM ((rewards r
     LEFT JOIN reward_metric_storages rms ON ((rms.reward_id = r.id)))
     LEFT JOIN surveys s ON ((s.reward_id = r.id)));


CREATE OR REPLACE VIEW "1"."user_details" AS
 SELECT u.id,
    u.common_id,
        CASE
            WHEN ((u.deactivated_at IS NOT NULL) AND (NOT is_owner_or_admin(u.id))) THEN (''::character varying(255))::text
            ELSE u.name
        END AS name,
    u.deactivated_at,
    thumbnail_image(u.*) AS profile_img_thumbnail,
        CASE
            WHEN ((u.deactivated_at IS NOT NULL) AND (NOT is_owner_or_admin(u.id))) THEN ''::character varying(255)
            ELSE u.facebook_link
        END AS facebook_link,
        CASE
            WHEN ((u.deactivated_at IS NOT NULL) AND (NOT is_owner_or_admin(u.id))) THEN ''::character varying(255)
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
            WHEN is_owner_or_admin(u.id) THEN u.cpf
            ELSE NULL::text
        END AS owner_document,
    cover_image_url(u.*) AS profile_cover_image,
    u.created_at,
        CASE
            WHEN ((u.deactivated_at IS NOT NULL) AND (NOT is_owner_or_admin(u.id))) THEN NULL::text
            ELSE u.about_html
        END AS about_html,
    is_owner_or_admin(u.id) AS is_owner_or_admin,
        CASE
            WHEN ((u.deactivated_at IS NOT NULL) AND (NOT is_owner_or_admin(u.id))) THEN false
            ELSE u.newsletter
        END AS newsletter,
        CASE
            WHEN ((u.deactivated_at IS NOT NULL) AND (NOT is_owner_or_admin(u.id))) THEN false
            ELSE u.subscribed_to_project_posts
        END AS subscribed_to_project_posts,
        CASE
            WHEN ((u.deactivated_at IS NOT NULL) AND (NOT is_owner_or_admin(u.id))) THEN false
            ELSE u.subscribed_to_new_followers
        END AS subscribed_to_new_followers,
        CASE
            WHEN ((u.deactivated_at IS NOT NULL) AND (NOT is_owner_or_admin(u.id))) THEN false
            ELSE u.subscribed_to_friends_contributions
        END AS subscribed_to_friends_contributions,
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
    ("current_user"() = 'admin'::name) AS is_admin_role,
        CASE
            WHEN is_owner_or_admin(u.id) THEN json_agg(json_build_object('user_marketing_list_id', mmu.id, 'marketing_list', row_to_json(mml.*)))
            ELSE NULL::json
        END AS mail_marketing_lists
  FROM ((((users u
     LEFT JOIN "1".user_totals ut ON ((ut.user_id = u.id)))
     LEFT JOIN addresses add ON ((add.id = u.address_id)))
     LEFT JOIN mail_marketing_users mmu ON ((mmu.user_id = u.id)))
     LEFT JOIN mail_marketing_lists mml ON ((mml.id = mmu.mail_marketing_list_id)))
  GROUP BY u.id, add.*, ut.total_contributed_projects, ut.total_published_projects;

    SQL
  end
end
