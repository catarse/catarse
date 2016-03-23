class AdjustsOnProjectTransfers < ActiveRecord::Migration
    def up
    execute <<-SQL
set statement_timeout to 0;

CREATE OR REPLACE VIEW "1".project_transfers AS
 SELECT p.id AS project_id,
    p.service_fee,
    p.goal,
    pt.paid_pledged as pledged,
    zone_timestamp(p.expires_at) AS expires_at,
    zone_timestamp(COALESCE(successful_at(p.*), failed_at(p.*))) AS finished_at,
    pt.paid_total_payment_service_fee AS gateway_fee,
    total_catarse_fee(p.*) AS catarse_fee,
    total_catarse_fee_without_gateway_fee(p.*) AS catarse_fee_without_gateway,
    (pt.pledged - total_catarse_fee(p.*)) AS amount_without_catarse_fee,
    irrf_tax(p.*) AS irrf_tax,
    pcc_tax(p.*) AS pcc_tax,
    (((pt.paid_pledged - total_catarse_fee(p.*)) + irrf_tax(p.*)) + pcc_tax(p.*)) AS total_amount
   FROM (projects p
     LEFT JOIN "1".project_totals pt ON ((pt.project_id = p.id)))
   WHERE public.is_owner_or_admin(p.user_id);

CREATE OR REPLACE FUNCTION total_catarse_fee(project projects) RETURNS numeric
    LANGUAGE sql STABLE
    AS $$
        SELECT
            p.service_fee * pt.paid_pledged
        FROM public.projects p
        LEFT JOIN "1".project_totals pt
            ON pt.project_id = p.id
        WHERE p.id = project.id;
    $$;

CREATE OR REPLACE FUNCTION total_catarse_fee_without_gateway_fee(project projects) RETURNS numeric
    LANGUAGE sql STABLE
    AS $$
        SELECT
            (p.service_fee * pt.paid_pledged) - pt.paid_total_payment_service_fee
        FROM public.projects p
        LEFT JOIN "1".project_totals pt
            ON pt.project_id = p.id
        WHERE p.id = project.id;
    $$;

    SQL
  end

  def down
    execute <<-SQL
set statement_timeout to 0;

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
    (pt.pledged - total_catarse_fee(p.*)) AS amount_without_catarse_fee,
    irrf_tax(p.*) AS irrf_tax,
    pcc_tax(p.*) AS pcc_tax,
    (((pt.pledged - total_catarse_fee(p.*)) + irrf_tax(p.*)) + pcc_tax(p.*)) AS total_amount
   FROM (projects p
     LEFT JOIN "1".project_totals pt ON ((pt.project_id = p.id)));

CREATE OR REPLACE FUNCTION total_catarse_fee(project projects) RETURNS numeric
    LANGUAGE sql STABLE
    AS $$
        SELECT
            p.service_fee * pt.pledged
        FROM public.projects p
        LEFT JOIN "1".project_totals pt
            ON pt.project_id = p.id
        WHERE p.id = project.id;
    $$;

CREATE OR REPLACE FUNCTION total_catarse_fee_without_gateway_fee(project projects) RETURNS numeric
    LANGUAGE sql STABLE
    AS $$
        SELECT
            (p.service_fee * pt.pledged) - pt.total_payment_service_fee
        FROM public.projects p
        LEFT JOIN "1".project_totals pt
            ON pt.project_id = p.id
        WHERE p.id = project.id;
    $$;

    SQL
  end
end
