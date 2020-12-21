class AddAntifraudCostToProjectTotals < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
      CREATE OR REPLACE VIEW "1".project_totals AS
      SELECT
        c.project_id,
        sum(p.value) AS pledged,
        sum(p.value) FILTER (WHERE p.state = 'paid'::text) AS paid_pledged,
        sum(p.value) / projects.goal * 100::numeric AS progress,
        sum(p.gateway_fee) AS total_payment_service_fee,
        sum(p.gateway_fee) FILTER (WHERE p.state = 'paid'::text) AS paid_total_payment_service_fee,
        count(DISTINCT c.id) AS total_contributions,
        count(DISTINCT c.user_id) AS total_contributors,
        sum(COALESCE(aa.cost, 0)) AS total_antifraud_cost,
        sum(COALESCE(aa.cost, 0)) FILTER (WHERE p.state = 'paid'::text) AS paid_total_antifraud_cost
      FROM contributions c
      JOIN projects ON c.project_id = projects.id
      JOIN payments p ON p.contribution_id = c.id
      LEFT JOIN antifraud_analyses aa ON p.id = aa.payment_id
      WHERE
        CASE
          WHEN projects.state::text <> ALL (ARRAY['failed'::text, 'rejected'::text]) THEN
            p.state = 'paid'::text
          ELSE
            p.state = ANY (confirmed_states())
        END
      GROUP BY c.project_id, projects.id;
    SQL
  end

  def down
    execute <<-SQL
      CREATE OR REPLACE VIEW "1".project_totals AS
      SELECT
        c.project_id,
        sum(p.value) AS pledged,
        sum(p.value) FILTER (WHERE p.state = 'paid'::text) AS paid_pledged,
        sum(p.value) / projects.goal * 100::numeric AS progress,
        sum(p.gateway_fee) AS total_payment_service_fee,
        sum(p.gateway_fee) FILTER (WHERE p.state = 'paid'::text) AS paid_total_payment_service_fee,
        count(DISTINCT c.id) AS total_contributions,
        count(DISTINCT c.user_id) AS total_contributors
      FROM contributions c
      JOIN projects ON c.project_id = projects.id
      JOIN payments p ON p.contribution_id = c.id
      WHERE
        CASE
          WHEN projects.state::text <> ALL (ARRAY['failed'::text, 'rejected'::text]) THEN
            p.state = 'paid'::text
          ELSE
            p.state = ANY (confirmed_states())
        END
      GROUP BY c.project_id, projects.id;
    SQL
  end
end
