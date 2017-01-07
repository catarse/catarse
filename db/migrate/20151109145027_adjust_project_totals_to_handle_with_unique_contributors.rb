class AdjustProjectTotalsToHandleWithUniqueContributors < ActiveRecord::Migration
  def up
    execute <<-SQL
SET statement_timeout TO 0;
    SQL

    execute <<-SQL
SELECT deps_save_and_drop_dependencies('1', 'project_totals');

DROP VIEW "1".project_totals;
CREATE VIEW "1".project_totals AS
SELECT c.project_id,
  sum(p.value) AS pledged,
  sum(p.value) / projects.goal * 100::numeric AS progress,
  sum(p.gateway_fee) AS total_payment_service_fee,
  count(DISTINCT c.id) AS total_contributions,
  count(DISTINCT c.user_id) AS total_contributors
FROM
  contributions c
  JOIN projects ON c.project_id = projects.id
  JOIN payments p ON p.contribution_id = c.id
WHERE p.state::text = ANY (confirmed_states())
GROUP BY c.project_id, projects.id;

SELECT deps_restore_dependencies('1', 'project_totals');

SELECT deps_save_and_drop_dependencies('1', 'project_details');
DROP VIEW "1".project_details;
CREATE VIEW "1".project_details AS 
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
    COALESCE(pt.progress, 0::numeric) AS progress,
    COALESCE(pt.pledged, 0::numeric) AS pledged,
    COALESCE(pt.total_contributions, 0::bigint) AS total_contributions,
    COALESCE(pt.total_contributors, 0::bigint) AS total_contributors,
    COALESCE(fp.state, p.state) as state,
    p.mode,
    p.state_order,
    p.expires_at,
    zone_expires_at(p.*) AS zone_expires_at,
    p.online_date,
    p.sent_to_analysis_at,
    is_published(p.*) AS is_published,
    is_expired(p.*) AS is_expired,
    open_for_contributions(p.*) AS open_for_contributions,
    p.online_days,
    remaining_time_json(p.*) AS remaining_time,
    ( SELECT count(pp_1.*) AS count
           FROM project_posts pp_1
          WHERE pp_1.project_id = p.id) AS posts_count,
    json_build_object('city', COALESCE(ct.name, u.address_city), 'state_acronym', COALESCE(st.acronym, u.address_state::character varying), 'state', COALESCE(st.name, u.address_state::character varying)) AS address,
    json_build_object('id', u.id, 'name', u.name) AS "user",
    count(DISTINCT pn.*) FILTER (WHERE pn.template_name = 'reminder'::text) AS reminder_count,
    is_owner_or_admin(p.user_id) AS is_owner_or_admin,
    user_signed_in() AS user_signed_in,
    current_user_already_in_reminder(p.*) AS in_reminder,
    count(pp.*) AS total_posts,
    "current_user"() = 'admin'::name AS is_admin_role
   FROM projects p
     JOIN categories c ON c.id = p.category_id
     JOIN users u ON u.id = p.user_id
     LEFT JOIN public.flexible_projects fp on fp.project_id = p.id
     LEFT JOIN project_posts pp ON pp.project_id = p.id
     LEFT JOIN "1".project_totals pt ON pt.project_id = p.id
     LEFT JOIN cities ct ON ct.id = p.city_id
     LEFT JOIN states st ON st.id = ct.state_id
     LEFT JOIN project_notifications pn ON pn.project_id = p.id
  GROUP BY p.id, c.id, u.id, c.name_pt, ct.name, u.address_city, st.acronym, u.address_state, st.name, pt.progress, pt.pledged, pt.total_contributions, p.state, p.expires_at, p.sent_to_analysis_at, pt.total_payment_service_fee, fp.state, pt.total_contributors;

select deps_restore_dependencies('1', 'project_details');

grant select on "1".project_details to admin;
grant select on "1".project_details to web_user;
grant select on "1".project_details to anonymous;
    SQL
  end

  def down
    execute <<-SQL
SET statement_timeout TO 0;
    SQL

    execute <<-SQL
SELECT deps_save_and_drop_dependencies('1', 'project_details');
DROP VIEW "1".project_details;
CREATE VIEW "1".project_details AS 
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
    COALESCE(pt.progress, 0::numeric) AS progress,
    COALESCE(pt.pledged, 0::numeric) AS pledged,
    COALESCE(pt.total_contributions, 0::bigint) AS total_contributions,
    COALESCE(fp.state, p.state) as state,
    p.mode,
    p.state_order,
    p.expires_at,
    zone_expires_at(p.*) AS zone_expires_at,
    p.online_date,
    p.sent_to_analysis_at,
    is_published(p.*) AS is_published,
    is_expired(p.*) AS is_expired,
    open_for_contributions(p.*) AS open_for_contributions,
    p.online_days,
    remaining_time_json(p.*) AS remaining_time,
    ( SELECT count(pp_1.*) AS count
           FROM project_posts pp_1
          WHERE pp_1.project_id = p.id) AS posts_count,
    json_build_object('city', COALESCE(ct.name, u.address_city), 'state_acronym', COALESCE(st.acronym, u.address_state::character varying), 'state', COALESCE(st.name, u.address_state::character varying)) AS address,
    json_build_object('id', u.id, 'name', u.name) AS "user",
    count(DISTINCT pn.*) FILTER (WHERE pn.template_name = 'reminder'::text) AS reminder_count,
    is_owner_or_admin(p.user_id) AS is_owner_or_admin,
    user_signed_in() AS user_signed_in,
    current_user_already_in_reminder(p.*) AS in_reminder,
    count(pp.*) AS total_posts,
    "current_user"() = 'admin'::name AS is_admin_role
   FROM projects p
     JOIN categories c ON c.id = p.category_id
     JOIN users u ON u.id = p.user_id
     LEFT JOIN public.flexible_projects fp on fp.project_id = p.id
     LEFT JOIN project_posts pp ON pp.project_id = p.id
     LEFT JOIN "1".project_totals pt ON pt.project_id = p.id
     LEFT JOIN cities ct ON ct.id = p.city_id
     LEFT JOIN states st ON st.id = ct.state_id
     LEFT JOIN project_notifications pn ON pn.project_id = p.id
  GROUP BY p.id, c.id, u.id, c.name_pt, ct.name, u.address_city, st.acronym, u.address_state, st.name, pt.progress, pt.pledged, pt.total_contributions, p.state, p.expires_at, p.sent_to_analysis_at, pt.total_payment_service_fee, fp.state;

select deps_restore_dependencies('1', 'project_details');

grant select on "1".project_details to admin;
grant select on "1".project_details to web_user;
grant select on "1".project_details to anonymous;

SELECT deps_save_and_drop_dependencies('1', 'project_totals');

DROP VIEW "1".project_totals;
CREATE VIEW "1".project_totals AS
SELECT c.project_id,
  sum(p.value) AS pledged,
  sum(p.value) / projects.goal * 100::numeric AS progress,
  sum(p.gateway_fee) AS total_payment_service_fee,
  count(DISTINCT c.id) AS total_contributions
FROM
  contributions c
  JOIN projects ON c.project_id = projects.id
  JOIN payments p ON p.contribution_id = c.id
WHERE p.state::text = ANY (confirmed_states())
GROUP BY c.project_id, projects.id;

SELECT deps_restore_dependencies('1', 'project_totals');

    SQL
  end
end
