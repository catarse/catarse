class AddUniqueIndexesOnBalanceTransactions < ActiveRecord::Migration[4.2]
  def up
    execute %Q{
create unique index idx_contribution_chargeback_evt_uniq on balance_transactions(event_name, contribution_id) where event_name = 'contribution_chargedback';
create unique index idx_subscription_payment_chargeback_evt_uniq on balance_transactions(event_name, subscription_payment_uuid) where event_name = 'subscription_payment_chargedback';
create unique index idx_balance_expired_evt_uniq on balance_transactions(event_name, contribution_id) where event_name = 'balance_expired';
create unique index idx_contrbution_refunded_after_successful_pledged_evt_uniq on balance_transactions(event_name, contribution_id) where event_name = 'contrbution_refunded_after_successful_pledged';
create unique index idx_subscription_payment_refunded_evt_uniq on balance_transactions(event_name, subscription_payment_uuid) where event_name = 'subscription_payment_refunded';

}
  end

  def down
    execute %Q{
drop index idx_contribution_chargeback_evt_uniq;
drop index idx_subscription_payment_chargeback_evt_uniq;
drop index idx_balance_expired_evt_uniq;
drop index idx_contrbution_refunded_after_successful_pledged_evt_uniq;
drop index idx_subscription_payment_refunded_evt_uniq;
}
  end
end
