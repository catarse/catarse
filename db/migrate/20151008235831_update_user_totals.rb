class UpdateUserTotals < ActiveRecord::Migration
  def change
    execute <<-SQL

      DROP VIEW "1".team_members;
      DROP VIEW "1".user_details;
      DROP VIEW "1".project_contributions;

      DROP MATERIALIZED VIEW "1".user_totals;

      CREATE MATERIALIZED VIEW "1".user_totals AS 
      SELECT u.id,
          u.id as user_id,
          coalesce(ct.total_contributed_projects, 0) as total_contributed_projects,
          coalesce(ct.sum, 0) as sum,
          coalesce(ct.count, 0) as count,
          case when u.zero_credits THEN 0 ELSE coalesce(ct.credits, 0) END as credits,
          coalesce(( SELECT count(*) AS count
              FROM projects p2
              WHERE is_published(p2.*) AND p2.user_id = u.id), 0) AS total_published_projects
      FROM users u
          LEFT JOIN (
      SELECT
          c.user_id,
          count(DISTINCT c.project_id) AS total_contributed_projects,
          sum(pa.value) AS sum,
          count(DISTINCT c.id) AS count,
          sum(
              CASE
          WHEN lower(pa.gateway) = 'pagarme'::text THEN 0::numeric
          WHEN p.state::text <> 'failed'::text AND NOT uses_credits(pa.*) THEN 0::numeric
          WHEN p.state::text = 'failed'::text AND uses_credits(pa.*) THEN 0::numeric
          WHEN p.state::text = 'failed'::text AND ((pa.state = ANY (ARRAY['pending_refund'::character varying::text, 'refunded'::character varying::text])) AND NOT uses_credits(pa.*) OR uses_credits(pa.*) AND NOT (pa.state = ANY (ARRAY['pending_refund'::character varying::text, 'refunded'::character varying::text]))) THEN 0::numeric
          WHEN p.state::text = 'failed'::text AND NOT uses_credits(pa.*) AND pa.state = 'paid'::text THEN pa.value
          ELSE pa.value * (-1)::numeric
              END
          ) - (SELECT sum(amount)/100 from user_transfers ut WHERE ut.status = 'transferred' AND ut.user_id = c.user_id) AS credits
              FROM 
          contributions c
          JOIN payments pa ON c.id = pa.contribution_id
          JOIN projects p ON c.project_id = p.id

      WHERE pa.state = ANY (confirmed_states())
      GROUP BY c.user_id
          ) ct ON u.id = ct.user_id;

      CREATE VIEW "1".team_members AS
       SELECT u.id,
          u.name,
          public.thumbnail_image(u.*) AS img,
          COALESCE(ut.total_contributed_projects, (0)::bigint) AS total_contributed_projects,
          COALESCE(ut.sum, (0)::numeric) AS total_amount_contributed
         FROM (public.users u
           LEFT JOIN "1".user_totals ut ON ((ut.user_id = u.id)))
        WHERE u.admin
        ORDER BY u.name;

      grant select on "1".team_members to anonymous;
      grant select on "1".team_members to admin;
      grant select on "1".team_members to web_user;

      CREATE VIEW "1".user_details AS
       SELECT u.id,
          u.name,
          u.address_city,
          public.thumbnail_image(u.*) AS profile_img_thumbnail,
          u.facebook_link,
          u.twitter AS twitter_username,
              CASE
                  WHEN ("current_user"() = 'anonymous'::name) THEN NULL::text
                  WHEN (public.is_owner_or_admin(u.id) OR public.has_published_projects(u.*)) THEN u.email
                  ELSE NULL::text
              END AS email,
          COALESCE(ut.total_contributed_projects, (0)::bigint) AS total_contributed_projects,
          COALESCE(ut.total_published_projects, (0)::bigint) AS total_published_projects,
          ( SELECT json_agg(DISTINCT ul.link) AS json_agg
                 FROM public.user_links ul
                WHERE (ul.user_id = u.id)) AS links
         FROM (public.users u
           LEFT JOIN "1".user_totals ut ON ((ut.user_id = u.id)));

      grant select on "1".user_details to admin;
      grant select on "1".user_details to web_user;
      grant select on "1".user_details to anonymous;

      CREATE VIEW "1".project_contributions AS
       SELECT c.anonymous,
          c.project_id,
          c.id,
          public.thumbnail_image(u.*) AS profile_img_thumbnail,
          u.id AS user_id,
          u.name AS user_name,
              CASE
                  WHEN public.is_owner_or_admin(p.user_id) THEN c.value
                  ELSE NULL::numeric
              END AS value,
          public.waiting_payment(pa.*) AS waiting_payment,
          public.is_owner_or_admin(p.user_id) AS is_owner_or_admin,
          ut.total_contributed_projects,
          c.created_at
         FROM ((((public.contributions c
           JOIN public.users u ON ((c.user_id = u.id)))
           JOIN public.projects p ON ((p.id = c.project_id)))
           JOIN public.payments pa ON ((pa.contribution_id = c.id)))
           LEFT JOIN "1".user_totals ut ON ((ut.user_id = u.id)))
        WHERE ((public.was_confirmed(c.*) OR public.waiting_payment(pa.*)) AND ((NOT c.anonymous) OR public.is_owner_or_admin(p.user_id)));

      grant select on "1".project_contributions to admin;
      grant select on "1".project_contributions to web_user;
      grant select on "1".project_contributions to anonymous;
     SQL
  end
end
