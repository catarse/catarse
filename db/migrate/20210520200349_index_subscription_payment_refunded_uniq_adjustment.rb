class IndexSubscriptionPaymentRefundedUniqAdjustment < ActiveRecord::Migration[6.1]
  def up
    execute %Q{
      drop index if exists idx_subscription_payment_refunded_evt_uniq;
      create unique index idx_subscription_payment_refunded_evt_uniq on balance_transactions(event_name, subscription_payment_uuid, user_id) where event_name = 'subscription_payment_refunded';
    }
  end

  def down
    execute %Q{
      drop index if exists idx_subscription_payment_refunded_evt_uniq;
      create unique index idx_subscription_payment_refunded_evt_uniq on balance_transactions(event_name, subscription_payment_uuid) where event_name = 'subscription_payment_refunded';
    }
  end
end
