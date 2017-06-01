class DontUseUserAddressOnProjectDetails < ActiveRecord::Migration
  def change
    execute %Q{
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
            WHEN ((p.state)::text = 'failed'::text) THEN pt.pledged
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
          WHERE ((is_confirmed(c_1.*) AND (uf.user_id = current_user_id())) AND (c_1.project_id = p.id)))) AS contributed_by_friends,
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
        CASE
            WHEN ("current_user"() = 'admin'::name) THEN p.service_fee
            ELSE NULL::numeric
        END AS service_fee
   FROM ((((((((projects p
     JOIN categories c ON ((c.id = p.category_id)))
     JOIN users u ON ((u.id = p.user_id)))
     LEFT JOIN "1".project_totals pt ON ((pt.project_id = p.id)))
     LEFT JOIN cities ct ON ((ct.id = p.city_id)))
     LEFT JOIN states st ON ((st.id = ct.state_id)))
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
  GROUP BY posts_size.count, ct.id, p.id, c.id, u.id, c.name_pt, ct.name, u.address_city, st.acronym, u.address_state, st.name, pt.progress, pt.pledged, pt.paid_pledged, pt.total_contributions, p.state, p.expires_at, pt.total_payment_service_fee, pt.total_contributors;
}
  end
end
