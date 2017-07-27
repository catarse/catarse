class AddTotalAmountTaxIncludedToProjects < ActiveRecord::Migration
  def up
    execute %Q{
create or replace function public.total_amount_tax_included(p public.projects) returns numeric
    language sql as $$
        select
            (pt.paid_pledged - public.total_catarse_fee(p.*)) + irrf_tax(p.*)
        from "1".project_totals pt
            join users u on u.id = p.user_id
            where pt.project_id = p.id;
    $$;
comment on function public.total_amount_tax_included(p public.projects) is 'Total amount of paid pledged with tax apply';
}
  end

  def down
    execute %Q{
drop function public.total_amount_tax_included(p public.projects);
}
  end
end
