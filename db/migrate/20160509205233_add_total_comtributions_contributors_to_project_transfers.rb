class AddTotalComtributionsContributorsToProjectTransfers < ActiveRecord::Migration
  def up
    execute %Q{
DROP VIEW "1".project_transfers;
CREATE VIEW "1".project_transfers AS
 SELECT p.id AS project_id,
    p.service_fee,
    p.goal,
    pt.paid_pledged AS pledged,
    pt.total_contributions,
    pt.total_contributors,
    public.zone_timestamp(p.expires_at) AS expires_at,
    public.zone_timestamp(COALESCE(public.successful_at(p.*), public.failed_at(p.*))) AS finished_at,
    pt.paid_total_payment_service_fee AS gateway_fee,
    public.total_catarse_fee(p.*) AS catarse_fee,
    public.total_catarse_fee_without_gateway_fee(p.*) AS catarse_fee_without_gateway,
    (pt.pledged - public.total_catarse_fee(p.*)) AS amount_without_catarse_fee,
    public.irrf_tax(p.*) AS irrf_tax,
    (((pt.paid_pledged - public.total_catarse_fee(p.*)) + public.irrf_tax(p.*))) AS total_amount
   FROM (public.projects p
     LEFT JOIN "1".project_totals pt ON ((pt.project_id = p.id)))
  WHERE (public.is_owner_or_admin(p.user_id) OR ("current_user"() = 'catarse'::name));

GRANT select ON "1".project_transfers TO admin, web_user;
    }
  end

  def down
    execute %Q{
DROP VIEW "1".project_transfers;
CREATE VIEW "1".project_transfers AS
 SELECT p.id AS project_id,
    p.service_fee,
    p.goal,
    pt.paid_pledged AS pledged,
    public.zone_timestamp(p.expires_at) AS expires_at,
    public.zone_timestamp(COALESCE(public.successful_at(p.*), public.failed_at(p.*))) AS finished_at,
    pt.paid_total_payment_service_fee AS gateway_fee,
    public.total_catarse_fee(p.*) AS catarse_fee,
    public.total_catarse_fee_without_gateway_fee(p.*) AS catarse_fee_without_gateway,
    (pt.pledged - public.total_catarse_fee(p.*)) AS amount_without_catarse_fee,
    public.irrf_tax(p.*) AS irrf_tax,
    (((pt.paid_pledged - public.total_catarse_fee(p.*)) + public.irrf_tax(p.*))) AS total_amount
   FROM (public.projects p
     LEFT JOIN "1".project_totals pt ON ((pt.project_id = p.id)))
  WHERE (public.is_owner_or_admin(p.user_id) OR ("current_user"() = 'catarse'::name));

GRANT select ON "1".project_transfers TO admin, web_user;
    }
  end
end
