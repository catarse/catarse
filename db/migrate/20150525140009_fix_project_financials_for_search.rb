class FixProjectFinancialsForSearch < ActiveRecord::Migration
  def change
    execute <<-SQL
     CREATE OR REPLACE VIEW project_financials AS(
     WITH catarse_fee_percentage AS (
         SELECT c.value::numeric AS total,
            1::numeric - c.value::numeric AS complement
           FROM settings c
          WHERE c.name = 'catarse_fee'::text
        ), catarse_base_url AS (
         SELECT c.value
           FROM settings c
          WHERE c.name = 'base_url'::text
        )
      SELECT
        p.id AS project_id,
        p.name,
        u.moip_login AS moip,
        p.goal,
        pt.pledged AS reached,
        pt.total_payment_service_fee AS payment_tax,
        cp.total * pt.pledged AS catarse_fee,
        pt.pledged * cp.complement AS repass_value,
        to_char(expires_at(p.*) AT TIME ZONE coalesce((SELECT value FROM settings WHERE name = 'timezone'), 'America/Sao_Paulo'), 'dd/mm/yyyy'::text) AS expires_at,
        (catarse_base_url.value || '/admin/reports/contribution_reports.csv?project_id='::text) || p.id AS contribution_report,
        p.state
      FROM projects p
      JOIN users u ON u.id = p.user_id
      LEFT JOIN "1".project_totals pt ON pt.project_id = p.id
      CROSS JOIN catarse_fee_percentage cp
      CROSS JOIN catarse_base_url)
    SQL
  end
end

