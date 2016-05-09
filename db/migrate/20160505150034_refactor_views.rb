class RefactorViews < ActiveRecord::Migration
  def change
    execute <<-SQL
    CREATE OR REPLACE VIEW "1".projects AS
    SELECT p.id AS project_id,
    p.category_id,
    p.name AS project_name,
    p.headline,
    p.permalink,
    p.mode,
    p.state::text,
    so.so AS state_order,
    od.od AS online_date,
    p.recommended,
    thumbnail_image(p.*, 'large'::text) AS project_img,
    remaining_time_json(p.*) AS remaining_time,
    p.expires_at,
    COALESCE(( SELECT
                CASE
                    WHEN p.state::text = 'failed'::text THEN pt.pledged
                    ELSE pt.paid_pledged
                END AS paid_pledged
           FROM "1".project_totals pt
          WHERE pt.project_id = p.id), 0::numeric) AS pledged,
    COALESCE(( SELECT pt.progress
           FROM "1".project_totals pt
          WHERE pt.project_id = p.id), 0::numeric) AS progress,
    s.acronym AS state_acronym,
    u.name AS owner_name,
    c.name AS city_name,
    p.full_text_index,
    is_current_and_online(p.expires_at, p.state::text) AS open_for_contributions
   FROM projects p
     JOIN users u ON p.user_id = u.id
     JOIN cities c ON c.id = p.city_id
     JOIN states s ON s.id = c.state_id
     JOIN LATERAL zone_timestamp(online_at(p.*)) od(od) ON true
     JOIN LATERAL state_order(p.*) so(so) ON true;

    grant select on "1".projects to admin;
    grant select on "1".projects to web_user;
    grant select on "1".projects to anonymous;

    CREATE OR REPLACE FUNCTION can_deliver(project_reminders) RETURNS boolean
        LANGUAGE sql STABLE SECURITY DEFINER
        AS $_$
    select exists (
    select true from projects p
    where p.expires_at is not null
    and p.id = $1.project_id
    and p.state = 'online'
    and public.is_past((p.expires_at - '48 hours'::interval))
    and not exists (select true from project_notifications pn
    where pn.user_id = $1.user_id and pn.project_id = $1.project_id
    and pn.template_name = 'reminder'));
    $_$;

    CREATE OR REPLACE FUNCTION open_for_contributions(projects) RETURNS boolean
        LANGUAGE sql STABLE
        AS $_$
        SELECT public.is_current_and_online($1.expires_at, $1.state );
    $_$;


    CREATE OR REPLACE VIEW "1".contribution_details AS
     SELECT pa.id,
        c.id AS contribution_id,
        pa.id AS payment_id,
        c.user_id,
        c.project_id,
        c.reward_id,
        p.permalink,
        p.name AS project_name,
        public.thumbnail_image(p.*) AS project_img,
        public.zone_timestamp(public.online_at(p.*)) AS project_online_date,
        public.zone_timestamp(p.expires_at) AS project_expires_at,
        p.state AS project_state,
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
        public.zone_timestamp(pa.created_at) AS created_at,
        public.zone_timestamp(pa.created_at) AS pending_at,
        public.zone_timestamp(pa.paid_at) AS paid_at,
        public.zone_timestamp(pa.refused_at) AS refused_at,
        public.zone_timestamp(pa.pending_refund_at) AS pending_refund_at,
        public.zone_timestamp(pa.refunded_at) AS refunded_at,
        public.zone_timestamp(pa.deleted_at) AS deleted_at,
        public.zone_timestamp(pa.chargeback_at) AS chargeback_at,
        pa.full_text_index,
        public.waiting_payment(pa.*) AS waiting_payment
       FROM (((public.projects p
         JOIN public.contributions c ON ((c.project_id = p.id)))
         JOIN public.payments pa ON ((c.id = pa.contribution_id)))
         JOIN public.users u ON ((c.user_id = u.id)));

    GRANT select ON "1".contribution_details TO admin;
    GRANT update ON "1".contribution_details TO admin;


    CREATE OR REPLACE VIEW "1".project_transitions AS
     SELECT project_transitions.project_id,
        project_transitions.to_state AS state,
        project_transitions.metadata,
        project_transitions.most_recent,
        project_transitions.created_at
       FROM public.project_transitions ;

    GRANT select ON "1".project_transitions TO admin, web_user, anonymous;

    DROP MATERIALIZED VIEW "1".finished_projects;
    CREATE MATERIALIZED VIEW "1".finished_projects AS
     SELECT p.id AS project_id,
        p.category_id,
        p.name AS project_name,
        p.headline,
        p.permalink,
        public.mode(p.*) AS mode,
        p.state::text AS state,
        so.so AS state_order,
        od.od AS online_date,
        p.recommended,
        public.thumbnail_image(p.*, 'large'::text) AS project_img,
        public.remaining_time_json(p.*) AS remaining_time,
        p.expires_at,
        COALESCE(( SELECT pt.pledged
               FROM "1".project_totals pt
              WHERE (pt.project_id = p.id)), (0)::numeric) AS pledged,
        COALESCE(( SELECT pt.progress
               FROM "1".project_totals pt
              WHERE (pt.project_id = p.id)), (0)::numeric) AS progress,
        s.acronym AS state_acronym,
        u.name AS owner_name,
        c.name AS city_name,
        p.full_text_index,
        public.is_current_and_online(p.expires_at, (p.state)::text ) AS open_for_contributions
       FROM ((((((public.projects p
         JOIN public.users u ON ((p.user_id = u.id)))
         JOIN public.cities c ON ((c.id = p.city_id)))
         JOIN public.states s ON ((s.id = c.state_id)))
         JOIN LATERAL public.zone_timestamp(public.online_at(p.*)) od(od) ON (true))
         JOIN LATERAL public.state_order(p.*) so(so) ON (true)))
      WHERE (EXISTS ( SELECT true AS bool
               FROM "1".project_transitions pt
              WHERE (((pt.state)::text = ANY (ARRAY['successful'::text, 'waiting_funds'::text, 'failed'::text])) AND pt.most_recent AND (pt.project_id = p.id))))
      WITH NO DATA;

      GRANT SELECT ON "1".finished_projects TO anonymous, web_user, admin;

      DROP VIEW "1".project_details;
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
        COALESCE(
            CASE
                WHEN p.state::text = 'failed'::text THEN pt.pledged
                ELSE pt.paid_pledged
            END, 0::numeric) AS pledged,
        COALESCE(pt.total_contributions, 0::bigint) AS total_contributions,
        COALESCE(pt.total_contributors, 0::bigint) AS total_contributors,
        p.state::text AS state,
        mode(p.*) AS mode,
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
       FROM projects p
         JOIN categories c ON c.id = p.category_id
         JOIN users u ON u.id = p.user_id
         LEFT JOIN project_posts pp ON pp.project_id = p.id
         LEFT JOIN "1".project_totals pt ON pt.project_id = p.id
         LEFT JOIN cities ct ON ct.id = p.city_id
         LEFT JOIN states st ON st.id = ct.state_id
         LEFT JOIN project_reminders pr ON pr.project_id = p.id
      GROUP BY p.id, c.id, u.id, c.name_pt, ct.name, u.address_city, st.acronym, u.address_state, st.name, pt.progress, pt.pledged, pt.paid_pledged, pt.total_contributions, p.state, p.expires_at, pt.total_payment_service_fee, pt.total_contributors;

    grant select on "1".project_details to admin;
    grant select on "1".project_details to web_user;
    grant select on "1".project_details to anonymous;

    DROP MATERIALIZED VIEW "1".statistics;
    CREATE MATERIALIZED VIEW "1".statistics AS
     SELECT ( SELECT count(*) AS count
               FROM public.users) AS total_users,
        contributions_totals.total_contributions,
        contributions_totals.total_contributors,
        contributions_totals.total_contributed,
        projects_totals.total_projects,
        projects_totals.total_projects_success,
        projects_totals.total_projects_online
       FROM ( SELECT count(DISTINCT c.id) AS total_contributions,
                count(DISTINCT c.user_id) AS total_contributors,
                COALESCE(sum(p.value), (0)::numeric) AS total_contributed
               FROM (public.contributions c
                 JOIN public.payments p ON ((p.contribution_id = c.id)))
              WHERE (p.state = ANY (public.confirmed_states()))) contributions_totals,
        ( SELECT count(*) AS total_projects,
                count(
                    CASE
                        WHEN ( (p.state)::text = 'successful'::text) THEN 1
                        ELSE NULL::integer
                    END) AS total_projects_success,
                count(
                    CASE
                        WHEN ( (p.state)::text = 'online'::text) THEN 1
                        ELSE NULL::integer
                    END) AS total_projects_online
               FROM public.projects p
              WHERE ((p.state)::text <> ALL (ARRAY['draft'::text, 'rejected'::text]))) projects_totals
      WITH NO DATA;

    GRANT SELECT ON "1".statistics TO admin, web_user, anonymous;


    DROP MATERIALIZED VIEW "1".category_totals;
    CREATE MATERIALIZED VIEW "1".category_totals AS
     WITH project_stats AS (
             SELECT ca.id AS category_id,
                ca.name_pt AS name,
                count(DISTINCT p_1.id) FILTER (WHERE ( (p_1.state)::text = 'online'::text)) AS online_projects,
                count(DISTINCT p_1.id) FILTER (WHERE ( (p_1.state)::text = 'successful'::text)) AS successful_projects,
                count(DISTINCT p_1.id) FILTER (WHERE ( (p_1.state)::text = 'failed'::text)) AS failed_projects,
                avg(p_1.goal) AS avg_goal,
                avg(pt.pledged) AS avg_pledged,
                sum(pt.pledged) FILTER (WHERE ((p_1.state)::text = 'successful'::text)) AS total_successful_value,
                sum(pt.pledged) AS total_value
               FROM ((public.projects p_1
                 JOIN public.categories ca ON ((ca.id = p_1.category_id)))
                 LEFT JOIN project_totals pt ON ((pt.project_id = p_1.id)))
              WHERE ( (p_1.state)::text <> ALL (ARRAY[('draft'::character varying)::text, ('in_analysis'::character varying)::text, ('rejected'::character varying)::text]))
              GROUP BY ca.id
            ), contribution_stats AS (
             SELECT ca.id AS category_id,
                ca.name_pt,
                avg(pa.value) AS avg_value,
                count(DISTINCT c_1.user_id) AS total_contributors
               FROM (((public.projects p_1
                 JOIN public.categories ca ON ((ca.id = p_1.category_id)))
                 JOIN public.contributions c_1 ON ((c_1.project_id = p_1.id)))
                 JOIN public.payments pa ON ((pa.contribution_id = c_1.id)))
              WHERE (((p_1.state)::text <> ALL (ARRAY[('draft'::character varying)::text, ('in_analysis'::character varying)::text, ('rejected'::character varying)::text])) AND (pa.state = ANY (public.confirmed_states())))
              GROUP BY ca.id
            ), followers AS (
             SELECT cf_1.category_id,
                count(DISTINCT cf_1.user_id) AS followers
               FROM public.category_followers cf_1
              GROUP BY cf_1.category_id
            )
     SELECT p.category_id,
        p.name,
        p.online_projects,
        p.successful_projects,
        p.failed_projects,
        p.avg_goal,
        p.avg_pledged,
        p.total_successful_value,
        p.total_value,
        c.name_pt,
        c.avg_value,
        c.total_contributors,
        cf.followers
       FROM ((project_stats p
         JOIN contribution_stats c USING (category_id))
         LEFT JOIN followers cf USING (category_id))
      WITH NO DATA;

      GRANT SELECT ON "1".category_totals TO admin, anonymous, web_user;

    SQL
  end
end
