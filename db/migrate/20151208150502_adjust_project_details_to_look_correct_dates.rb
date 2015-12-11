class AdjustProjectDetailsToLookCorrectDates < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE OR REPLACE VIEW "1".project_details AS
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
    COALESCE(fp.state, p.state::text) AS state,
    mode(p.*) AS mode,
    state_order(p.*) AS state_order,
    p.expires_at,
    zone_timestamp(p.expires_at) AS zone_expires_at,
    p.online_at AS online_date,
    zone_timestamp(p.online_at) AS zone_online_date,
    zone_timestamp(p.in_analysis_at) as sent_to_analysis_at,
    is_published(p.*) AS is_published,
    is_expired(p.*) AS is_expired,
    open_for_contributions(p.*) AS open_for_contributions,
    p.online_days,
    remaining_time_json(p.*) AS remaining_time,
    elapsed_time_json(p.*) AS elapsed_time,
    ( SELECT count(pp_1.*) AS count
           FROM project_posts pp_1
          WHERE pp_1.project_id = p.id) AS posts_count,
    json_build_object('city', COALESCE(ct.name, u.address_city), 'state_acronym', COALESCE(st.acronym, u.address_state::character varying), 'state', COALESCE(st.name, u.address_state::character varying)) AS address,
    json_build_object('id', u.id, 'name', u.name) AS "user",
    count(DISTINCT pr.user_id) AS reminder_count,
    is_owner_or_admin(p.user_id) AS is_owner_or_admin,
    user_signed_in() AS user_signed_in,
    current_user_already_in_reminder(p.*) AS in_reminder,
    count(pp.*) AS total_posts,
    "current_user"() = 'admin'::name AS is_admin_role
   FROM public.projects p
     JOIN public.categories c ON c.id = p.category_id
     JOIN public.users u ON u.id = p.user_id
     LEFT JOIN public.flexible_projects fp ON fp.project_id = p.id
     LEFT JOIN public.project_posts pp ON pp.project_id = p.id
     LEFT JOIN "1".project_totals pt ON pt.project_id = p.id
     LEFT JOIN public.cities ct ON ct.id = p.city_id
     LEFT JOIN public.states st ON st.id = ct.state_id
     LEFT JOIN public.project_reminders pr ON pr.project_id = p.id
  GROUP BY p.id, c.id, u.id, c.name_pt, ct.name, u.address_city, st.acronym, u.address_state,
    st.name, pt.progress, pt.pledged, pt.total_contributions, p.state, p.expires_at,
    pt.total_payment_service_fee, fp.state, pt.total_contributors;

CREATE OR REPLACE FUNCTION elapsed_time_json(projects) RETURNS json
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
            select public.interval_to_json(least(now(), $1.expires_at) - $1.online_at)
        $_$;

CREATE OR REPLACE VIEW projects_in_analysis_by_periods AS
 WITH weeks AS (
         SELECT to_char(current_year_1.current_year, 'yyyy-mm W'::text) AS current_year,
            to_char(last_year_1.last_year, 'yyyy-mm W'::text) AS last_year,
            current_year_1.current_year AS label
           FROM (generate_series((now() - '49 days'::interval), now(), '7 days'::interval) current_year_1(current_year)
             JOIN generate_series((now() - '1 year 49 days'::interval), (now() - '1 year'::interval), '7 days'::interval) last_year_1(last_year) ON ((to_char(last_year_1.last_year, 'mm W'::text) = to_char(current_year_1.current_year, 'mm W'::text))))
        ), current_year AS (
         SELECT w.label,
            count(*) AS current_year
           FROM (public.projects p
             JOIN weeks w ON ((w.current_year = to_char(p.in_analysis_at, 'yyyy-mm W'::text))))
          GROUP BY w.label
        ), last_year AS (
         SELECT w.label,
            count(*) AS last_year
           FROM (public.projects p
             JOIN weeks w ON ((w.last_year = to_char(p.in_analysis_at, 'yyyy-mm W'::text))))
          GROUP BY w.label
        )
 SELECT current_year.label,
    current_year.current_year,
    last_year.last_year
   FROM (current_year
     JOIN last_year USING (label));

    SQL
  end

  def down
    execute <<-SQL
CREATE OR REPLACE VIEW "1".project_details AS
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
    COALESCE(fp.state, p.state::text) AS state,
    mode(p.*) AS mode,
    state_order(p.*) AS state_order,
    p.expires_at,
    zone_timestamp(p.expires_at) AS zone_expires_at,
    p.online_date AS online_date,
    zone_timestamp(p.online_date) AS zone_online_date,
    p.sent_to_analysis_at,
    is_published(p.*) AS is_published,
    is_expired(p.*) AS is_expired,
    open_for_contributions(p.*) AS open_for_contributions,
    p.online_days,
    remaining_time_json(p.*) AS remaining_time,
    elapsed_time_json(p.*) AS elapsed_time,
    ( SELECT count(pp_1.*) AS count
           FROM project_posts pp_1
          WHERE pp_1.project_id = p.id) AS posts_count,
    json_build_object('city', COALESCE(ct.name, u.address_city), 'state_acronym', COALESCE(st.acronym, u.address_state::character varying), 'state', COALESCE(st.name, u.address_state::character varying)) AS address,
    json_build_object('id', u.id, 'name', u.name) AS "user",
    count(DISTINCT pr.user_id) AS reminder_count,
    is_owner_or_admin(p.user_id) AS is_owner_or_admin,
    user_signed_in() AS user_signed_in,
    current_user_already_in_reminder(p.*) AS in_reminder,
    count(pp.*) AS total_posts,
    "current_user"() = 'admin'::name AS is_admin_role
   FROM public.projects p
     JOIN public.categories c ON c.id = p.category_id
     JOIN public.users u ON u.id = p.user_id
     LEFT JOIN public.flexible_projects fp ON fp.project_id = p.id
     LEFT JOIN public.project_posts pp ON pp.project_id = p.id
     LEFT JOIN "1".project_totals pt ON pt.project_id = p.id
     LEFT JOIN public.cities ct ON ct.id = p.city_id
     LEFT JOIN public.states st ON st.id = ct.state_id
     LEFT JOIN public.project_reminders pr ON pr.project_id = p.id
  GROUP BY p.id, c.id, u.id, c.name_pt, ct.name, u.address_city, st.acronym, u.address_state,
    st.name, pt.progress, pt.pledged, pt.total_contributions, p.state, p.expires_at,
    pt.total_payment_service_fee, fp.state, pt.total_contributors, p.sent_to_analysis_at;

CREATE OR REPLACE FUNCTION elapsed_time_json(projects) RETURNS json
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
            select public.interval_to_json(least(now(), $1.expires_at) - $1.online_date)
        $_$;

CREATE OR REPLACE VIEW projects_in_analysis_by_periods AS
 WITH weeks AS (
         SELECT to_char(current_year_1.current_year, 'yyyy-mm W'::text) AS current_year,
            to_char(last_year_1.last_year, 'yyyy-mm W'::text) AS last_year,
            current_year_1.current_year AS label
           FROM (generate_series((now() - '49 days'::interval), now(), '7 days'::interval) current_year_1(current_year)
             JOIN generate_series((now() - '1 year 49 days'::interval), (now() - '1 year'::interval), '7 days'::interval) last_year_1(last_year) ON ((to_char(last_year_1.last_year, 'mm W'::text) = to_char(current_year_1.current_year, 'mm W'::text))))
        ), current_year AS (
         SELECT w.label,
            count(*) AS current_year
           FROM (public.projects p
             JOIN weeks w ON ((w.current_year = to_char(p.sent_to_analysis_at, 'yyyy-mm W'::text))))
          GROUP BY w.label
        ), last_year AS (
         SELECT w.label,
            count(*) AS last_year
           FROM (public.projects p
             JOIN weeks w ON ((w.last_year = to_char(p.sent_to_analysis_at, 'yyyy-mm W'::text))))
          GROUP BY w.label
        )
 SELECT current_year.label,
    current_year.current_year,
    last_year.last_year
   FROM (current_year
     JOIN last_year USING (label));

    SQL
  end
end
