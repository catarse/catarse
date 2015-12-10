class AddBalanceAndBalanceTransactionsView < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE OR REPLACE VIEW "1".balances AS 
    SELECT
        bt.user_id,
        sum(bt.amount) amount
    FROM public.balance_transactions bt
    WHERE public.is_owner_or_admin(user_id)
    GROUP BY user_id;

GRANT SELECT ON public.balance_transactions TO web_user, admin;
GRANT SELECT ON "1".balance_transactions TO web_user, admin;
GRANT SELECT ON "1".balances TO web_user, admin;

CREATE OR REPLACE VIEW "1".balance_transactions AS 
select
    user_id,
    amount,
    event_name,
    zone_timestamp(created_at)::date,
    created_at::date
from balance_transactions bt
where is_owner_or_admin(user_id)
order by created_at desc, id desc;in;

GRANT SELECT ON "1".balance_transactions TO web_user, admin;
    SQL
  end

  def down
    execute <<-SQL
DROP VIEW "1".balances;
DROP VIEW "1".balance_transactions;
    SQL
  end

end
