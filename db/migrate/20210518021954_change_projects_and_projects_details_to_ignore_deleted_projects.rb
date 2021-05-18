class ChangeProjectsAndProjectsDetailsToIgnoreDeletedProjects < ActiveRecord::Migration[6.1]
  def up
    execute %Q(
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
         COALESCE(((pt.data ->> 'progress'::text))::numeric, (0)::numeric) AS progress,
         COALESCE(
             CASE
                 WHEN ((p.state)::text = ANY (ARRAY[('failed'::character varying)::text, ('rejected'::character varying)::text])) THEN ((pt.data ->> 'pledged'::text))::numeric
                 ELSE ((pt.data ->> 'pledged'::text))::numeric
             END, (0)::numeric) AS pledged,
         COALESCE(((pt.data ->> 'total_contributions'::text))::bigint, (0)::bigint) AS total_contributions,
         COALESCE(((pt.data ->> 'total_contributors'::text))::bigint, (0)::bigint) AS total_contributors,
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
          where p.state not in ('deleted')
       GROUP BY posts_size.count, integrations_size.count, ct.id, p.id, c.id, u.id, c.name_pt, ct.name, st.acronym, st.name, ((pt.data ->> 'progress'::text))::numeric, ((pt.data ->> 'pledged'::text))::numeric, ((pt.data ->> 'paid_pledged'::text))::numeric, ((pt.data ->> 'total_contributions'::text))::bigint, p.state, p.expires_at, ((pt.data ->> 'total_contributors'::text))::bigint;

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
          COALESCE(((pms.data ->> 'pledged'::text))::numeric, (0)::numeric) AS pledged,
          COALESCE(((pms.data ->> 'progress'::text))::numeric, (0)::numeric) AS progress,
          s.acronym AS state_acronym,
          u.name AS owner_name,
          c.name AS city_name,
          p.full_text_index,
          is_current_and_online(p.expires_at, (p.state)::text) AS open_for_contributions,
          elapsed_time_json(p.*) AS elapsed_time,
          COALESCE((pss.score)::numeric, (0)::numeric) AS score,
          (EXISTS ( SELECT true AS bool
                 FROM (contributions c_1
                   JOIN user_follows uf ON ((uf.follow_id = c_1.user_id)))
                WHERE (is_confirmed(c_1.*) AND (uf.user_id = current_user_id()) AND (c_1.project_id = p.id)))) AS contributed_by_friends,
          p.user_id AS project_user_id,
          p.video_embed_url,
          p.updated_at,
          u.public_name AS owner_public_name,
          zone_timestamp(p.expires_at) AS zone_expires_at,
          p.common_id,
          (p.content_rating >= 18) AS is_adult_content,
          p.content_rating,
          (EXISTS ( SELECT true AS bool
                 FROM project_reminders pr
                WHERE ((p.id = pr.project_id) AND (pr.user_id = current_user_id())))) AS saved_projects,
          ( SELECT array_to_string(array_agg(COALESCE((integration.data ->> 'name'::text), (integration.name)::text)), ','::text) AS integration_name
                 FROM project_integrations integration
                WHERE (integration.project_id = p.id)) AS integrations,
          COALESCE(category.name_pt, (category.name_en)::text) AS category_name
         FROM ((((((((projects p
           JOIN users u ON ((p.user_id = u.id)))
           LEFT JOIN project_score_storages pss ON ((pss.project_id = p.id)))
           LEFT JOIN project_metric_storages pms ON ((pms.project_id = p.id)))
           LEFT JOIN cities c ON ((c.id = p.city_id)))
           LEFT JOIN states s ON ((s.id = c.state_id)))
           JOIN LATERAL zone_timestamp(online_at(p.*)) od(od) ON (true))
           JOIN LATERAL state_order(p.*) so(so) ON (true))
           LEFT JOIN categories category ON ((category.id = p.category_id)))
           where p.state not in ('deleted');
    )
  end

  def down
    execute %Q(
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
         COALESCE(((pt.data ->> 'progress'::text))::numeric, (0)::numeric) AS progress,
         COALESCE(
             CASE
                 WHEN ((p.state)::text = ANY (ARRAY[('failed'::character varying)::text, ('rejected'::character varying)::text])) THEN ((pt.data ->> 'pledged'::text))::numeric
                 ELSE ((pt.data ->> 'pledged'::text))::numeric
             END, (0)::numeric) AS pledged,
         COALESCE(((pt.data ->> 'total_contributions'::text))::bigint, (0)::bigint) AS total_contributions,
         COALESCE(((pt.data ->> 'total_contributors'::text))::bigint, (0)::bigint) AS total_contributors,
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
       GROUP BY posts_size.count, integrations_size.count, ct.id, p.id, c.id, u.id, c.name_pt, ct.name, st.acronym, st.name, ((pt.data ->> 'progress'::text))::numeric, ((pt.data ->> 'pledged'::text))::numeric, ((pt.data ->> 'paid_pledged'::text))::numeric, ((pt.data ->> 'total_contributions'::text))::bigint, p.state, p.expires_at, ((pt.data ->> 'total_contributors'::text))::bigint;

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
          COALESCE(((pms.data ->> 'pledged'::text))::numeric, (0)::numeric) AS pledged,
          COALESCE(((pms.data ->> 'progress'::text))::numeric, (0)::numeric) AS progress,
          s.acronym AS state_acronym,
          u.name AS owner_name,
          c.name AS city_name,
          p.full_text_index,
          is_current_and_online(p.expires_at, (p.state)::text) AS open_for_contributions,
          elapsed_time_json(p.*) AS elapsed_time,
          COALESCE((pss.score)::numeric, (0)::numeric) AS score,
          (EXISTS ( SELECT true AS bool
                 FROM (contributions c_1
                   JOIN user_follows uf ON ((uf.follow_id = c_1.user_id)))
                WHERE (is_confirmed(c_1.*) AND (uf.user_id = current_user_id()) AND (c_1.project_id = p.id)))) AS contributed_by_friends,
          p.user_id AS project_user_id,
          p.video_embed_url,
          p.updated_at,
          u.public_name AS owner_public_name,
          zone_timestamp(p.expires_at) AS zone_expires_at,
          p.common_id,
          (p.content_rating >= 18) AS is_adult_content,
          p.content_rating,
          (EXISTS ( SELECT true AS bool
                 FROM project_reminders pr
                WHERE ((p.id = pr.project_id) AND (pr.user_id = current_user_id())))) AS saved_projects,
          ( SELECT array_to_string(array_agg(COALESCE((integration.data ->> 'name'::text), (integration.name)::text)), ','::text) AS integration_name
                 FROM project_integrations integration
                WHERE (integration.project_id = p.id)) AS integrations,
          COALESCE(category.name_pt, (category.name_en)::text) AS category_name
         FROM ((((((((projects p
           JOIN users u ON ((p.user_id = u.id)))
           LEFT JOIN project_score_storages pss ON ((pss.project_id = p.id)))
           LEFT JOIN project_metric_storages pms ON ((pms.project_id = p.id)))
           LEFT JOIN cities c ON ((c.id = p.city_id)))
           LEFT JOIN states s ON ((s.id = c.state_id)))
           JOIN LATERAL zone_timestamp(online_at(p.*)) od(od) ON (true))
           JOIN LATERAL state_order(p.*) so(so) ON (true))
           LEFT JOIN categories category ON ((category.id = p.category_id)));
    )
  end
end
