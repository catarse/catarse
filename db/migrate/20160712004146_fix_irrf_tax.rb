class FixIrrfTax < ActiveRecord::Migration
  def change
    execute <<-SQL
    CREATE OR REPLACE FUNCTION irrf_tax(project projects) RETURNS numeric
        LANGUAGE sql STABLE
        AS $$
            SELECT
                CASE
                WHEN char_length(pa.owner_document) > 14 AND p.total_catarse_fee_without_gateway_fee >= 666.66 THEN
                    0.015 * p.total_catarse_fee_without_gateway_fee
                ELSE 0 END
            FROM public.projects p
            LEFT JOIN public.project_accounts pa
                ON pa.project_id = p.id
            WHERE p.id = project.id;
        $$;
    SQL

  end
end
