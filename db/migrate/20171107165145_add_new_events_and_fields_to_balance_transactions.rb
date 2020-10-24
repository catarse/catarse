class AddNewEventsAndFieldsToBalanceTransactions < ActiveRecord::Migration[4.2]
  def up
    add_column :balance_transactions, :subscription_payment_id, :integer, foreign_key: true
    execute %Q{
create unique index balance_subscription_fee_evt_uniq
    on public.balance_transactions (event_name, subscription_payment_id)
    where event_name = 'subscription_fee'::text;

create unique index balance_subscription_payment_evt_uniq
    on public.balance_transactions (event_name, subscription_payment_id)
    where event_name = 'subscription_payment'::text;
}
  end

  def down
    remove_column :balance_transactions, :subscription_payment_id
    execute %Q{
    drop index if exists balance_subscription_payment_evt_uniq;
    drop index if exists balance_subscription_fee_evt_uniq;
}
  end
end
