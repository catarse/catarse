class ChangeOnlineDateType < ActiveRecord::Migration
  def up
    execute <<-SQL
SET statement_timeout TO 0;
    SQL

    execute <<-SQL
-- this view is used in one dataclip, so I'm not restoring it
DROP MATERIALIZED VIEW IF EXISTS temp.projects_and_contributors_per_day;

-- this view is not used since the new home works with the projects endpoint
-- also will not be restored
DROP VIEW IF EXISTS "1".projects_for_home;

DROP VIEW "1".project_details;
DROP VIEW "1".contribution_details;
DROP VIEW "1".projects CASCADE;

ALTER TABLE public.projects ALTER online_date TYPE timestamp;

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
     LEFT JOIN project_totals pt ON ((pt.project_id = p.id)))
     LEFT JOIN public.cities ct ON ((ct.id = p.city_id)))
     LEFT JOIN public.states st ON ((st.id = ct.state_id)))
     LEFT JOIN public.project_notifications pn ON ((pn.project_id = p.id)))
  GROUP BY p.id, c.id, u.id, c.name_pt, ct.name, u.address_city, st.acronym, u.address_state, st.name, pt.progress, pt.pledged, pt.total_contributions, p.state, p.expires_at, p.sent_to_analysis_at, pt.total_payment_service_fee, fp.state, pt.total_contributors;

REVOKE ALL ON TABLE "1".project_details FROM PUBLIC;
GRANT ALL ON TABLE "1".project_details TO catarse;
GRANT SELECT ON TABLE "1".project_details TO admin;
GRANT SELECT ON TABLE "1".project_details TO web_user;
GRANT SELECT ON TABLE "1".project_details TO anonymous;

CREATE VIEW "1".contribution_details AS
 SELECT pa.id,
    c.id AS contribution_id,
    pa.id AS payment_id,
    c.user_id,
    c.project_id,
    c.reward_id,
    p.permalink,
    p.name AS project_name,
    public.thumbnail_image(p.*) AS project_img,
    p.online_date AS project_online_date,
    p.expires_at AS project_expires_at,
    (COALESCE(fp.state, (p.state)::text))::character varying(255) AS project_state,
    u.name AS user_name,
    public.thumbnail_image(u.*) AS user_profile_img,
    u.email,
    c.anonymous,
    c.payer_email,
    pa.key,
    pa.value,
    pa.installments,
    pa.installment_value,
    pa.state,
    public.is_second_slip(pa.*) AS is_second_slip,
    pa.gateway,
    pa.gateway_id,
    pa.gateway_fee,
    pa.gateway_data,
    pa.payment_method,
    pa.created_at,
    pa.created_at AS pending_at,
    pa.paid_at,
    pa.refused_at,
    pa.pending_refund_at,
    pa.refunded_at,
    pa.deleted_at,
    pa.chargeback_at,
    pa.full_text_index,
    public.waiting_payment(pa.*) AS waiting_payment
   FROM ((((public.projects p
     LEFT JOIN public.flexible_projects fp ON ((fp.project_id = p.id)))
     JOIN public.contributions c ON ((c.project_id = p.id)))
     JOIN public.payments pa ON ((c.id = pa.contribution_id)))
     JOIN public.users u ON ((c.user_id = u.id)));

CREATE TRIGGER update_from_details_to_contributions INSTEAD OF UPDATE ON "1".contribution_details FOR EACH ROW EXECUTE PROCEDURE public.update_from_details_to_contributions();

REVOKE ALL ON TABLE "1".contribution_details FROM PUBLIC;
GRANT ALL ON TABLE "1".contribution_details TO catarse;
GRANT SELECT,UPDATE ON TABLE "1".contribution_details TO admin;

CREATE VIEW "1".projects AS
 SELECT p.id AS project_id,
    p.name AS project_name,
    p.headline,
    p.permalink,
    public.mode(p.*) AS mode,
    COALESCE(fp.state, (p.state)::text) AS state,
    public.state_order(p.*) AS state_order,
    p.online_date,
    p.recommended,
    public.thumbnail_image(p.*, 'large'::text) AS project_img,
    public.remaining_time_json(p.*) AS remaining_time,
    p.expires_at,
    COALESCE(( SELECT pt.pledged
           FROM project_totals pt
          WHERE (pt.project_id = p.id)), (0)::numeric) AS pledged,
    COALESCE(( SELECT pt.progress
           FROM project_totals pt
          WHERE (pt.project_id = p.id)), (0)::numeric) AS progress,
    COALESCE(s.acronym, (pa.address_state)::character varying(255)) AS state_acronym,
    u.name AS owner_name,
    COALESCE(c.name, pa.address_city) AS city_name
   FROM (((((public.projects p
     JOIN public.users u ON ((p.user_id = u.id)))
     LEFT JOIN public.flexible_projects fp ON ((fp.project_id = p.id)))
     LEFT JOIN public.project_accounts pa ON ((pa.project_id = p.id)))
     LEFT JOIN public.cities c ON ((c.id = p.city_id)))
     LEFT JOIN public.states s ON ((s.id = c.state_id)));


REVOKE ALL ON TABLE "1".projects FROM PUBLIC;
GRANT ALL ON TABLE "1".projects TO catarse;
GRANT SELECT ON TABLE "1".projects TO admin;
GRANT SELECT ON TABLE "1".projects TO web_user;
GRANT SELECT ON TABLE "1".projects TO anonymous;

CREATE FUNCTION public.listing_order(project "1".projects) RETURNS integer
    LANGUAGE sql STABLE
    AS $$
    SELECT
        CASE project.state
            WHEN 'online' THEN 1
            WHEN 'waiting_funds' THEN 2
            WHEN 'successful' THEN 3
            WHEN 'failed' THEN 4
        END;
$$;

CREATE FUNCTION public.near_me("1".projects) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
          SELECT
      COALESCE($1.state_acronym, (SELECT pa.address_state FROM project_accounts pa WHERE pa.project_id = $1.project_id)) = (SELECT u.address_state FROM users u WHERE u.id = current_user_id())
        $_$;

CREATE FUNCTION "1".project_search(query text) RETURNS SETOF "1".projects
    LANGUAGE sql STABLE
    AS $$
SELECT
    p.*
FROM
    "1".projects p
    JOIN public.projects pr ON pr.id = p.project_id
WHERE
    (
        pr.full_text_index @@ to_tsquery('portuguese', unaccent(query))
        OR
        pr.name % query
    )
    AND pr.state_order >= 'published'
ORDER BY
    p.listing_order,
    ts_rank(pr.full_text_index, to_tsquery('portuguese', unaccent(query))) DESC,
    pr.id DESC;
$$;
    SQL
  end

  def down
    execute <<-SQL
SET statement_timeout TO 0;
    SQL

    execute <<-SQL
DROP VIEW "1".project_details;
DROP VIEW "1".contribution_details;
DROP VIEW "1".projects CASCADE;

ALTER TABLE public.projects ALTER online_date TYPE timestamptz;

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
     LEFT JOIN project_totals pt ON ((pt.project_id = p.id)))
     LEFT JOIN public.cities ct ON ((ct.id = p.city_id)))
     LEFT JOIN public.states st ON ((st.id = ct.state_id)))
     LEFT JOIN public.project_notifications pn ON ((pn.project_id = p.id)))
  GROUP BY p.id, c.id, u.id, c.name_pt, ct.name, u.address_city, st.acronym, u.address_state, st.name, pt.progress, pt.pledged, pt.total_contributions, p.state, p.expires_at, p.sent_to_analysis_at, pt.total_payment_service_fee, fp.state, pt.total_contributors;

REVOKE ALL ON TABLE "1".project_details FROM PUBLIC;
GRANT ALL ON TABLE "1".project_details TO catarse;
GRANT SELECT ON TABLE "1".project_details TO admin;
GRANT SELECT ON TABLE "1".project_details TO web_user;
GRANT SELECT ON TABLE "1".project_details TO anonymous;

CREATE VIEW "1".contribution_details AS
 SELECT pa.id,
    c.id AS contribution_id,
    pa.id AS payment_id,
    c.user_id,
    c.project_id,
    c.reward_id,
    p.permalink,
    p.name AS project_name,
    public.thumbnail_image(p.*) AS project_img,
    p.online_date AS project_online_date,
    p.expires_at AS project_expires_at,
    (COALESCE(fp.state, (p.state)::text))::character varying(255) AS project_state,
    u.name AS user_name,
    public.thumbnail_image(u.*) AS user_profile_img,
    u.email,
    c.anonymous,
    c.payer_email,
    pa.key,
    pa.value,
    pa.installments,
    pa.installment_value,
    pa.state,
    public.is_second_slip(pa.*) AS is_second_slip,
    pa.gateway,
    pa.gateway_id,
    pa.gateway_fee,
    pa.gateway_data,
    pa.payment_method,
    pa.created_at,
    pa.created_at AS pending_at,
    pa.paid_at,
    pa.refused_at,
    pa.pending_refund_at,
    pa.refunded_at,
    pa.deleted_at,
    pa.chargeback_at,
    pa.full_text_index,
    public.waiting_payment(pa.*) AS waiting_payment
   FROM ((((public.projects p
     LEFT JOIN public.flexible_projects fp ON ((fp.project_id = p.id)))
     JOIN public.contributions c ON ((c.project_id = p.id)))
     JOIN public.payments pa ON ((c.id = pa.contribution_id)))
     JOIN public.users u ON ((c.user_id = u.id)));

CREATE TRIGGER update_from_details_to_contributions INSTEAD OF UPDATE ON "1".contribution_details FOR EACH ROW EXECUTE PROCEDURE public.update_from_details_to_contributions();

REVOKE ALL ON TABLE "1".contribution_details FROM PUBLIC;
GRANT ALL ON TABLE "1".contribution_details TO catarse;
GRANT SELECT,UPDATE ON TABLE "1".contribution_details TO admin;

CREATE VIEW "1".projects AS
 SELECT p.id AS project_id,
    p.name AS project_name,
    p.headline,
    p.permalink,
    public.mode(p.*) AS mode,
    COALESCE(fp.state, (p.state)::text) AS state,
    public.state_order(p.*) AS state_order,
    p.online_date,
    p.recommended,
    public.thumbnail_image(p.*, 'large'::text) AS project_img,
    public.remaining_time_json(p.*) AS remaining_time,
    p.expires_at,
    COALESCE(( SELECT pt.pledged
           FROM project_totals pt
          WHERE (pt.project_id = p.id)), (0)::numeric) AS pledged,
    COALESCE(( SELECT pt.progress
           FROM project_totals pt
          WHERE (pt.project_id = p.id)), (0)::numeric) AS progress,
    COALESCE(s.acronym, (pa.address_state)::character varying(255)) AS state_acronym,
    u.name AS owner_name,
    COALESCE(c.name, pa.address_city) AS city_name
   FROM (((((public.projects p
     JOIN public.users u ON ((p.user_id = u.id)))
     LEFT JOIN public.flexible_projects fp ON ((fp.project_id = p.id)))
     LEFT JOIN public.project_accounts pa ON ((pa.project_id = p.id)))
     LEFT JOIN public.cities c ON ((c.id = p.city_id)))
     LEFT JOIN public.states s ON ((s.id = c.state_id)));


REVOKE ALL ON TABLE "1".projects FROM PUBLIC;
GRANT ALL ON TABLE "1".projects TO catarse;
GRANT SELECT ON TABLE "1".projects TO admin;
GRANT SELECT ON TABLE "1".projects TO web_user;
GRANT SELECT ON TABLE "1".projects TO anonymous;

CREATE FUNCTION public.listing_order(project "1".projects) RETURNS integer
    LANGUAGE sql STABLE
    AS $$
    SELECT
        CASE project.state
            WHEN 'online' THEN 1
            WHEN 'waiting_funds' THEN 2
            WHEN 'successful' THEN 3
            WHEN 'failed' THEN 4
        END;
$$;

CREATE FUNCTION public.near_me("1".projects) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
          SELECT
      COALESCE($1.state_acronym, (SELECT pa.address_state FROM project_accounts pa WHERE pa.project_id = $1.project_id)) = (SELECT u.address_state FROM users u WHERE u.id = current_user_id())
        $_$;

CREATE FUNCTION "1".project_search(query text) RETURNS SETOF "1".projects
    LANGUAGE sql STABLE
    AS $$
SELECT
    p.*
FROM
    "1".projects p
    JOIN public.projects pr ON pr.id = p.project_id
WHERE
    (
        pr.full_text_index @@ to_tsquery('portuguese', unaccent(query))
        OR
        pr.name % query
    )
    AND pr.state_order >= 'published'
ORDER BY
    p.listing_order,
    ts_rank(pr.full_text_index, to_tsquery('portuguese', unaccent(query))) DESC,
    pr.id DESC;
$$;
    SQL
  end
end
