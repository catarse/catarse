class FixProjectTransfers < ActiveRecord::Migration
  def change
    execute <<-SQL
CREATE OR REPLACE VIEW "1".project_transfers AS
 SELECT p.id AS project_id,
    p.service_fee,
    p.goal,
    pt.pledged,
    zone_timestamp(p.expires_at) AS expires_at,
    zone_timestamp(COALESCE(successful_at(p.*), failed_at(p.*))) AS finished_at,
    pt.total_payment_service_fee AS gateway_fee,
    total_catarse_fee(p.*) AS catarse_fee,
    total_catarse_fee_without_gateway_fee(p.*) AS catarse_fee_without_gateway,
    pt.pledged - total_catarse_fee(p.*) AS amount_without_catarse_fee,
    irrf_tax(p.*) AS irrf_tax,
    pcc_tax(p.*) AS pcc_tax,
    pt.pledged - total_catarse_fee(p.*) + irrf_tax(p.*) + pcc_tax(p.*) AS total_amount
   FROM public.projects p
     LEFT JOIN "1".project_totals pt ON pt.project_id = p.id;
    SQL
  end
end
