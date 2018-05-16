class AdjustTotalAmountTaxIncludedToRemoveIrrfTaxFromCalculation < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE FUNCTION public.total_amount_tax_included(p projects)
 RETURNS numeric
 LANGUAGE sql
AS $function$
        select
            (pt.paid_pledged - public.total_catarse_fee(p.*))
        from "1".project_totals pt
            join users u on u.id = p.user_id
            where pt.project_id = p.id;
    $function$;
}
  end

  def down
    execute %Q{
    CREATE OR REPLACE FUNCTION public.total_amount_tax_included(p projects)
 RETURNS numeric
 LANGUAGE sql
AS $function$
        select
            (pt.paid_pledged - public.total_catarse_fee(p.*)) + irrf_tax(p.*)
        from "1".project_totals pt
            join users u on u.id = p.user_id
            where pt.project_id = p.id;
    $function$

}
  end
end
