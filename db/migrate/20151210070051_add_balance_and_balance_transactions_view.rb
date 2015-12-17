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
GRANT SELECT ON "1".balances TO web_user, admin;

CREATE OR REPLACE VIEW "1".balance_transactions AS
    select
        user_id,
        sum((case when amount > 0 then amount else 0 end)) as credit,
        sum((case when amount < 0 then amount else 0 end)) as debit,
        sum(amount) as total_amount,
        zone_timestamp(created_at)::date as created_at,
        json_agg(json_build_object(
            'amount', amount,
            'event_name', event_name,
            'origin_object', json_build_object(
                'id',coalesce(bt.project_id, bt.contribution_id),
                'references_to', (
                    case when bt.project_id is not null
                        then 'project'
                    when bt.contribution_id is not null
                        then 'contribution'
                    else null end),
                'name', (
                    case when bt.project_id is not null
                        then (select name from projects where id = bt.project_id)
                    else null end)
            )
        )) as source
    from balance_transactions bt
    where is_owner_or_admin(user_id)
    group by bt.created_at, bt.user_id
    order by created_at desc;

GRANT SELECT ON "1".balance_transactions TO web_user, admin;
    SQL
  end

  def down
    #remove_column :balances, :balance_transaction_id
    execute <<-SQL
DROP VIEW "1".balances;
DROP VIEW "1".balance_transactions;
    SQL
  end

end
