class AddFinancialFuncs < ActiveRecord::Migration
  def up
    execute <<-SQL
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

CREATE OR REPLACE FUNCTION irrf_tax(project projects) RETURNS numeric
    LANGUAGE sql STABLE
    AS $$
        SELECT
            CASE
            WHEN char_length(pa.owner_document) > 14 AND p.total_catarse_fee >= 666.66 THEN
                0.015 * p.total_catarse_fee_without_gateway_fee
            ELSE 0 END
        FROM public.projects p
        LEFT JOIN public.project_accounts pa
            ON pa.project_id = p.id
        WHERE p.id = project.id;
    $$;

CREATE OR REPLACE FUNCTION pcc_tax(project projects) RETURNS numeric
    LANGUAGE sql STABLE
    AS $$
        SELECT
            CASE
            WHEN char_length(pa.owner_document) > 14 AND p.total_catarse_fee >= 215.05 THEN
                0.0465 * p.total_catarse_fee_without_gateway_fee
            ELSE 0 END
        FROM public.projects p
        LEFT JOIN public.project_accounts pa
            ON pa.project_id = p.id
        WHERE p.id = project.id;
    $$;
    SQL
  end

  def down
    execute <<-SQL
DROP FUNCTION total_catarse_fee(project projects);
DROP FUNCTION total_catarse_fee_without_gateway_fee(project projects);
DROP FUNCTION irrf_tax(project projects);
DROP FUNCTION pcc_tax(project projects);
    SQL
  end
end
