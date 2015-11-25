class AddZoneOnlineDateToProjectDetails < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE OR REPLACE FUNCTION public.zone_timestamp(timestamp)
 RETURNS timestamp without time zone
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
        SELECT $1::timestamptz AT TIME ZONE settings('timezone');
      $function$;

CREATE OR REPLACE FUNCTION public.zone_expires_at(projects)
 RETURNS timestamp without time zone
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
        SELECT public.zone_timestamp($1.expires_at);
      $function$;


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
    public.original_image(p.*) AS original_image,
    public.thumbnail_image(p.*, 'thumb'::text) AS thumb_image,
    public.thumbnail_image(p.*, 'small'::text) AS small_image,
    public.thumbnail_image(p.*, 'large'::text) AS large_image,
    public.thumbnail_image(p.*, 'video_cover'::text) AS video_cover_image,
    COALESCE(pt.progress, (0)::numeric) AS progress,
    COALESCE(pt.pledged, (0)::numeric) AS pledged,
    COALESCE(pt.total_contributions, (0)::bigint) AS total_contributions,
    COALESCE(pt.total_contributors, (0)::bigint) AS total_contributors,
    COALESCE(fp.state, (p.state)::text) AS state,
    public.mode(p.*) AS mode,
    public.state_order(p.*) AS state_order,
    p.expires_at,
    public.zone_timestamp(p.expires_at) AS zone_expires_at,
    p.online_date,
    public.zone_timestamp(p.online_date) as zone_online_date,
    p.sent_to_analysis_at,
    public.is_published(p.*) AS is_published,
    public.is_expired(p.*) AS is_expired,
    public.open_for_contributions(p.*) AS open_for_contributions,
    p.online_days,
    public.remaining_time_json(p.*) AS remaining_time,
    public.elapsed_time_json(p.*) AS elapsed_time,
    ( SELECT count(pp_1.*) AS count
           FROM public.project_posts pp_1
          WHERE (pp_1.project_id = p.id)) AS posts_count,
    json_build_object('city', COALESCE(ct.name, u.address_city), 'state_acronym', COALESCE(st.acronym, (u.address_state)::character varying), 'state', COALESCE(st.name, (u.address_state)::character varying)) AS address,
    json_build_object('id', u.id, 'name', u.name) AS "user",
    count(DISTINCT pn.*) FILTER (WHERE (pn.template_name = 'reminder'::text)) AS reminder_count,
    public.is_owner_or_admin(p.user_id) AS is_owner_or_admin,
    public.user_signed_in() AS user_signed_in,
    public.current_user_already_in_reminder(p.*) AS in_reminder,
    count(pp.*) AS total_posts,
    ("current_user"() = 'admin'::name) AS is_admin_role
   FROM ((((((((public.projects p
     JOIN public.categories c ON ((c.id = p.category_id)))
     JOIN public.users u ON ((u.id = p.user_id)))
     LEFT JOIN public.flexible_projects fp ON ((fp.project_id = p.id)))
     LEFT JOIN public.project_posts pp ON ((pp.project_id = p.id)))
     LEFT JOIN "1".project_totals pt ON ((pt.project_id = p.id)))
     LEFT JOIN public.cities ct ON ((ct.id = p.city_id)))
     LEFT JOIN public.states st ON ((st.id = ct.state_id)))
     LEFT JOIN public.project_notifications pn ON ((pn.project_id = p.id)))
  GROUP BY p.id, c.id, u.id, c.name_pt, ct.name, u.address_city, st.acronym, u.address_state, st.name, pt.progress, pt.pledged, pt.total_contributions, p.state, p.expires_at, p.sent_to_analysis_at, pt.total_payment_service_fee, fp.state, pt.total_contributors;


REVOKE ALL ON TABLE "1".project_details FROM PUBLIC;
GRANT SELECT ON TABLE "1".project_details TO admin;
GRANT SELECT ON TABLE "1".project_details TO web_user;
GRANT SELECT ON TABLE "1".project_details TO anonymous;
    SQL
  end

  def down
    execute <<-SQL
DROP FUNCTION public.zone_timestamp(timestamp) CASCADE;

CREATE OR REPLACE FUNCTION public.zone_expires_at(projects)
 RETURNS timestamp without time zone
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
        SELECT $1.expires_at::timestamptz AT TIME ZONE settings('timezone');
      $function$;

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
    public.original_image(p.*) AS original_image,
    public.thumbnail_image(p.*, 'thumb'::text) AS thumb_image,
    public.thumbnail_image(p.*, 'small'::text) AS small_image,
    public.thumbnail_image(p.*, 'large'::text) AS large_image,
    public.thumbnail_image(p.*, 'video_cover'::text) AS video_cover_image,
    COALESCE(pt.progress, (0)::numeric) AS progress,
    COALESCE(pt.pledged, (0)::numeric) AS pledged,
    COALESCE(pt.total_contributions, (0)::bigint) AS total_contributions,
    COALESCE(pt.total_contributors, (0)::bigint) AS total_contributors,
    COALESCE(fp.state, (p.state)::text) AS state,
    public.mode(p.*) AS mode,
    public.state_order(p.*) AS state_order,
    p.expires_at,
    public.zone_expires_at(p.*) AS zone_expires_at,
    p.online_date,
    p.sent_to_analysis_at,
    public.is_published(p.*) AS is_published,
    public.is_expired(p.*) AS is_expired,
    public.open_for_contributions(p.*) AS open_for_contributions,
    p.online_days,
    public.remaining_time_json(p.*) AS remaining_time,
    public.elapsed_time_json(p.*) AS elapsed_time,
    ( SELECT count(pp_1.*) AS count
           FROM public.project_posts pp_1
          WHERE (pp_1.project_id = p.id)) AS posts_count,
    json_build_object('city', COALESCE(ct.name, u.address_city), 'state_acronym', COALESCE(st.acronym, (u.address_state)::character varying), 'state', COALESCE(st.name, (u.address_state)::character varying)) AS address,
    json_build_object('id', u.id, 'name', u.name) AS "user",
    count(DISTINCT pn.*) FILTER (WHERE (pn.template_name = 'reminder'::text)) AS reminder_count,
    public.is_owner_or_admin(p.user_id) AS is_owner_or_admin,
    public.user_signed_in() AS user_signed_in,
    public.current_user_already_in_reminder(p.*) AS in_reminder,
    count(pp.*) AS total_posts,
    ("current_user"() = 'admin'::name) AS is_admin_role
   FROM ((((((((public.projects p
     JOIN public.categories c ON ((c.id = p.category_id)))
     JOIN public.users u ON ((u.id = p.user_id)))
     LEFT JOIN public.flexible_projects fp ON ((fp.project_id = p.id)))
     LEFT JOIN public.project_posts pp ON ((pp.project_id = p.id)))
     LEFT JOIN "1".project_totals pt ON ((pt.project_id = p.id)))
     LEFT JOIN public.cities ct ON ((ct.id = p.city_id)))
     LEFT JOIN public.states st ON ((st.id = ct.state_id)))
     LEFT JOIN public.project_notifications pn ON ((pn.project_id = p.id)))
  GROUP BY p.id, c.id, u.id, c.name_pt, ct.name, u.address_city, st.acronym, u.address_state, st.name, pt.progress, pt.pledged, pt.total_contributions, p.state, p.expires_at, p.sent_to_analysis_at, pt.total_payment_service_fee, fp.state, pt.total_contributors;


REVOKE ALL ON TABLE "1".project_details FROM PUBLIC;
GRANT SELECT ON TABLE "1".project_details TO admin;
GRANT SELECT ON TABLE "1".project_details TO web_user;
GRANT SELECT ON TABLE "1".project_details TO anonymous;
    SQL
  end
end
