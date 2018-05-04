class AddBalanceExpiredOnBalance < ActiveRecord::Migration
  def up
    execute %Q{
    create or replace function public.can_expire_on_balance(public.balance_transactions)
        returns boolean
            language sql
                as $$
                   select (case when $1.event_name = 'contribution_refund' and ($1.created_at + '90 days'::interval < now()) then
                       not exists (select true from public.balance_transactions t
                                                  where t.user_id=$1.user_id
                                                      and t.id > $1.id
                                                      and t.event_name in ('balance_transfer_request','balance_transfer_project')
                                              ) 
                       and not exists (
                                       select true from public.balance_transactions t
                                           where t.user_id = $1.user_id
                                                              and t.contribution_id = $1.contribution_id
                                                              and t.event_name = 'balance_expired'
                                                  )
                                      else false end);
                                          $$;


}
  end

  def down
		execute %Q{
			drop function public.can_expire_on_balance(public.balance_transactions);
		}
  end
end
