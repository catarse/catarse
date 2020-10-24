class AddMeiToIrrfTaxFunction < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.irrf_tax(project projects)
      RETURNS numeric
      LANGUAGE sql
      STABLE
      AS $function$
        SELECT
            CASE
            WHEN u.account_type IN ('pj', 'mei') AND p.total_catarse_fee_without_gateway_fee >= 666.66 THEN
                0.015 * p.total_catarse_fee_without_gateway_fee
            ELSE 0 END
        FROM public.projects p
        LEFT JOIN public.users u on u.id = p.user_id
        WHERE p.id = project.id;
      $function$;
    SQL
  end

  def down
    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.irrf_tax(project projects)
      RETURNS numeric
      LANGUAGE sql
      STABLE
      AS $function$
        SELECT
            CASE
            WHEN u.account_type = 'pj' AND p.total_catarse_fee_without_gateway_fee >= 666.66 THEN
                0.015 * p.total_catarse_fee_without_gateway_fee
            ELSE 0 END
        FROM public.projects p
        LEFT JOIN public.users u on u.id = p.user_id
        WHERE p.id = project.id;
      $function$;
    SQL
  end
end
