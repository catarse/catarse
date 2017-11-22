class AddInfoAboutLastTransferRequestOnBalance < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE VIEW "1".balances as 
    select
        id as user_id,
        balance.amount as amount,
        last_transfer.amount as last_transfer_amount,
        last_transfer.created_at as last_transfer_created_at,
        last_transfer.in_period_yet        
    from public.users u
        left join lateral (
            SELECT sum(bt.amount) AS amount
            FROM balance_transactions bt
            WHERE bt.user_id = u.id
        ) as balance on true
        left join lateral (
            select 
                (bt.amount * -1) as amount,
                bt.created_at,
                (to_char(bt.created_at, 'MM/YYY') = to_char(now(), 'MM/YYY')) as in_period_yet
            from balance_transactions bt
                where bt.user_id = u.id
                    and bt.event_name in ('balance_transfer_request', 'balance_transfer_project')
                    and not exists (
                        select true 
                            from balance_transactions bt2
                            where bt2.user_id = u.id
                                and bt2.created_at > bt.created_at
                                and bt2.event_name = 'balance_transfer_error'
                    )
                order by bt.created_at desc
                limit 1
        ) as last_transfer on true
        where is_owner_or_admin(u.id);
}
  end

  def down
    execute %Q{
drop view "1".balances;
CREATE OR REPLACE VIEW "1"."balances" AS 
 SELECT bt.user_id,
    sum(bt.amount) AS amount
   FROM balance_transactions bt
  WHERE is_owner_or_admin(bt.user_id)
  GROUP BY bt.user_id;
}
  end
end
