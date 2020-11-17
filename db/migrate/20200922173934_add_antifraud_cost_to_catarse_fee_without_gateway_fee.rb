class AddAntifraudCostToCatarseFeeWithoutGatewayFee < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.total_catarse_fee_without_gateway_fee(project projects)
        RETURNS numeric
        LANGUAGE sql
        STABLE
      AS $function$
        SELECT
            (p.service_fee * pt.paid_pledged) - pt.paid_total_payment_service_fee - pt.paid_total_antifraud_cost
        FROM public.projects p
        LEFT JOIN "1".project_totals pt ON pt.project_id = p.id
        WHERE p.id = project.id;
      $function$;
    SQL
  end

  def down
    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.total_catarse_fee_without_gateway_fee(project projects)
        RETURNS numeric
        LANGUAGE sql
        STABLE
      AS $function$
        SELECT
            (p.service_fee * pt.paid_pledged) - pt.paid_total_payment_service_fee
        FROM public.projects p
        LEFT JOIN "1".project_totals pt ON pt.project_id = p.id
        WHERE p.id = project.id;
      $function$;
    SQL
  end
end
