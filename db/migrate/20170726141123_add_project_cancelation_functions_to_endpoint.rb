class AddProjectCancelationFunctionsToEndpoint < ActiveRecord::Migration
  def up
    execute %Q{
create or replace function public.user_total_balance(u public.users) returns numeric
    language sql as $$
        select
            sum(amount)
        from public.balance_transactions bt
            where bt.user_id = u.id
    $$;
comment on function public.user_total_balance(u public.users) is 'uer total balance based on balance transactions amount';

create or replace function public.owner_has_balance_for_refund(p public.projects) returns boolean
    language sql as $$
        select
            public.user_total_balance(u.*) >= (pt.paid_pledged - public.total_catarse_fee(p.*)) + irrf_tax(p.*)
        from "1".project_totals pt
            join users u on u.id = p.user_id
            where pt.project_id = p.id;
    $$;
comment on function public.owner_has_balance_for_refund(p public.projects) is 'check if project owner has balance to refund contributions of project';

create or replace function public.can_cancel(p public.projects) returns boolean
    language sql as $$
        select
            CASE
            WHEN p.state in ('draft', 'rejected') THEN false
            WHEN p.state = 'successful' AND NOT public.owner_has_balance_for_refund(p.*) THEN false
            WHEN public.has_cancelation_request(p.*) THEN false
            ELSE
                true
            END
    $$;
comment on function public.can_cancel(p public.projects) is 'check if project can be canceled';
}
  end

  def down
    execute %Q{
drop function public.user_total_balance(u public.users);
drop function public.owner_has_balance_for_refund(p public.projects);
drop function public.can_cancel(p public.projects);
}
  end
end
