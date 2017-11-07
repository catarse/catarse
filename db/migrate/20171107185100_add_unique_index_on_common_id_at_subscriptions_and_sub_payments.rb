class AddUniqueIndexOnCommonIdAtSubscriptionsAndSubPayments < ActiveRecord::Migration
  def up
    execute %Q{
    create unique index uniq_common_id_at_subscriptions on subscriptions(common_id);
    create unique index uniq_common_id_at_subscription_payments on subscription_payments(common_id);
}
  end

  def down
    execute %Q{
    drop index if exists uniq_common_id_at_subscriptions;
    drop index if exists uniq_common_id_at_subscription_payments;
}
  end
end
