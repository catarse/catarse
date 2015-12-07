class AddProjectTransfers < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE OR REPLACE VIEW "1".project_transfers AS
    SELECT
        p.id as project_id,
        p.service_fee,
        p.goal,
        pt.pledged,
        public.zone_timestamp(p.expires_at) AS expires_at,
        public.zone_timestamp(coalesce(p.successful_at, p.failed_at)) as finished_at,
        pt.total_payment_service_fee as gateway_fee,
        p.total_catarse_fee as catarse_fee,
        p.total_catarse_fee_without_gateway_fee as catarse_fee_without_gateway,
        (pt.pledged - p.total_catarse_fee) as amount_without_catarse_fee,
        p.irrf_tax,
        p.pcc_tax,
        ((pt.pledged - p.total_catarse_fee) + p.irrf_tax + p.pcc_tax) as total_amount
        FROM public.projects p
        LEFT JOIN "1".project_totals pt
            ON pt.project_id = p.id;

GRANT select, update ON "1".project_transfers TO admin;
    SQL
  end

  def down
    execute <<-SQL
DROP VIEW "1".project_transfers;
    SQL
  end
end
