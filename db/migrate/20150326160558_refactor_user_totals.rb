class RefactorUserTotals < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION uses_credits(payments) RETURNS boolean AS $$
        SELECT $1.gateway = 'Credits';
      $$ LANGUAGE SQL;
      DROP VIEW IF EXISTS user_totals_detail;
      DROP VIEW user_totals;
      CREATE VIEW "1".user_totals AS
      SELECT b.user_id AS id,
        b.user_id,
        count(DISTINCT b.project_id) AS total_contributed_projects,
        sum(pa.value) AS sum,
        count(DISTINCT b.id) AS count,
        sum(
            CASE
                WHEN p.state::text <> 'failed'::text AND NOT pa.uses_credits THEN 0::numeric
                WHEN p.state::text = 'failed'::text AND pa.uses_credits THEN 0::numeric
                WHEN p.state::text = 'failed'::text AND ((pa.state::text = ANY (ARRAY['pending_refund'::character varying::text, 'refunded'::character varying::text])) AND NOT pa.uses_credits OR pa.uses_credits AND NOT (pa.state::text = ANY (ARRAY['pending_refund'::character varying::text, 'refunded'::character varying::text]))) THEN 0::numeric
                WHEN p.state::text = 'failed'::text AND NOT pa.uses_credits AND pa.state::text = 'paid'::text THEN pa.value
                ELSE pa.value * (-1)::numeric
            END) AS credits
      FROM 
        contributions b
        JOIN payments pa ON b.id = pa.contribution_id
        JOIN projects p ON b.project_id = p.id
      WHERE pa.state::text = ANY (confirmed_states())
      GROUP BY b.user_id;
    SQL
  end

  def down
    execute <<-SQL
      DROP VIEW "1".user_totals;
      CREATE VIEW user_totals AS
      SELECT b.user_id AS id,
        b.user_id,
        count(DISTINCT b.project_id) AS total_contributed_projects,
        sum(b.value) AS sum,
        count(*) AS count,
        sum(
            CASE
                WHEN p.state::text <> 'failed'::text AND NOT b.credits THEN 0::numeric
                WHEN p.state::text = 'failed'::text AND b.credits THEN 0::numeric
                WHEN p.state::text = 'failed'::text AND ((b.state::text = ANY (ARRAY['requested_refund'::character varying::text, 'refunded'::character varying::text])) AND NOT b.credits OR b.credits AND NOT (b.state::text = ANY (ARRAY['requested_refund'::character varying::text, 'refunded'::character varying::text]))) THEN 0::numeric
                WHEN p.state::text = 'failed'::text AND NOT b.credits AND b.state::text = 'confirmed'::text THEN b.value
                ELSE b.value * (-1)::numeric
            END) AS credits
       FROM contributions b
         JOIN projects p ON b.project_id = p.id
      WHERE b.state::text = ANY (ARRAY['confirmed'::character varying::text, 'requested_refund'::character varying::text, 'refunded'::character varying::text])
      GROUP BY b.user_id;
    SQL
  end
end
