class FixCreditsOnUserTotals < ActiveRecord::Migration
  def up
    execute <<-SQL
    DROP VIEW "1".team_members;
    DROP MATERIALIZED VIEW "1".user_totals;

    CREATE MATERIALIZED VIEW "1".user_totals AS
      SELECT b.user_id AS id,
        b.user_id,
        count(DISTINCT b.project_id) AS total_contributed_projects,
        sum(pa.value) AS sum,
        count(DISTINCT b.id) AS count,
        (
          CASE
            WHEN u.zero_credits THEN
             0::numeric
            ELSE
              sum(
                CASE
                  WHEN lower(pa.gateway) = 'pagarme' THEN 0::numeric
                  WHEN p.state::text <> 'failed'::text AND NOT uses_credits(pa.*) THEN 0::numeric
                  WHEN p.state::text = 'failed'::text AND uses_credits(pa.*) THEN 0::numeric
                  WHEN p.state::text = 'failed'::text AND ((pa.state = ANY (ARRAY['pending_refund'::character varying::text, 'refunded'::character varying::text])) AND NOT uses_credits(pa.*) OR uses_credits(pa.*) AND NOT (pa.state = ANY (ARRAY['pending_refund'::character varying::text, 'refunded'::character varying::text]))) THEN 0::numeric
                  WHEN p.state::text = 'failed'::text AND NOT uses_credits(pa.*) AND pa.state = 'paid'::text THEN pa.value
                  ELSE pa.value * (-1)::numeric
                END)
            END
        )  AS credits
      FROM contributions b
        JOIN payments pa ON b.id = pa.contribution_id
        JOIN projects p ON b.project_id = p.id
        JOIN users u ON u.id = b.user_id
      WHERE pa.state = ANY (confirmed_states())
      GROUP BY b.user_id, u.zero_credits;

      CREATE OR REPLACE VIEW "1".team_members AS (
        select
          u.id,
          u.name,
          u.profile_img_thumbnail as img,
          COALESCE(ut.total_contributed_projects, 0) as total_contributed_projects,
          COALESCE(ut.sum, 0) as total_amount_contributed
        from users u
        left join "1".user_totals ut on ut.user_id = u.id
        where u.admin
        order by u.name asc
      );

      GRANT SELECT on "1".team_members to admin;
      GRANT SELECT on "1".team_members to web_user;
      GRANT SELECT on "1".team_members to anonymous;
    SQL
  end

  def down
    execute <<-SQL
    DROP VIEW "1".team_members;
    DROP MATERIALIZED VIEW "1".user_totals;

    CREATE MATERIALIZED VIEW "1".user_totals AS
      SELECT b.user_id AS id,
        b.user_id,
        count(DISTINCT b.project_id) AS total_contributed_projects,
        sum(pa.value) AS sum,
        count(DISTINCT b.id) AS count,
        sum(
            CASE
                WHEN p.state::text <> 'failed'::text AND NOT uses_credits(pa.*) THEN 0::numeric
                WHEN p.state::text = 'failed'::text AND uses_credits(pa.*) THEN 0::numeric
                WHEN p.state::text = 'failed'::text AND ((pa.state = ANY (ARRAY['pending_refund'::character varying::text, 'refunded'::character varying::text])) AND NOT uses_credits(pa.*) OR uses_credits(pa.*) AND NOT (pa.state = ANY (ARRAY['pending_refund'::character varying::text, 'refunded'::character varying::text]))) THEN 0::numeric
                WHEN p.state::text = 'failed'::text AND NOT uses_credits(pa.*) AND pa.state = 'paid'::text THEN pa.value
                ELSE pa.value * (-1)::numeric
            END) AS credits
      FROM contributions b
        JOIN payments pa ON b.id = pa.contribution_id
        JOIN projects p ON b.project_id = p.id
      WHERE pa.state = ANY (confirmed_states())
      GROUP BY b.user_id;

      CREATE OR REPLACE VIEW "1".team_members AS (
        select
          u.id,
          u.name,
          u.profile_img_thumbnail as img,
          COALESCE(ut.total_contributed_projects, 0) as total_contributed_projects,
          COALESCE(ut.sum, 0) as total_amount_contributed
        from users u
        left join "1".user_totals ut on ut.user_id = u.id
        where u.admin
        order by u.name asc
      );

      GRANT SELECT on "1".team_members to admin;
      GRANT SELECT on "1".team_members to web_user;
      GRANT SELECT on "1".team_members to anonymous;
    SQL
  end
end
