class RefactorProjectTotals < ActiveRecord::Migration
  def up
    execute <<-SQL
      DROP VIEW IF EXISTS project_financials;
      DROP VIEW project_totals;
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
    SQL
  end

  def down
    execute <<-SQL
      DROP VIEW "1".project_totals;
      CREATE VIEW project_totals AS
      SELECT contributions.project_id,
        sum(contributions.value) AS pledged,
        sum(contributions.value) / projects.goal * 100::numeric AS progress,
        sum(contributions.payment_service_fee) AS total_payment_service_fee,
        count(*) AS total_contributions
      FROM contributions
         JOIN projects ON contributions.project_id = projects.id
      WHERE contributions.state::text = ANY (ARRAY['confirmed'::character varying::text, 'refunded'::character varying::text, 'requested_refund'::character varying::text])
      GROUP BY contributions.project_id, projects.goal;
    SQL
  end
end
