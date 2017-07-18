class AddContributionRefundToBalances < ActiveRecord::Migration
  def up
    execute %Q{
    create unique index idx_contribution_refund_evt_uniq on balance_transactions (event_name, contribution_id) where event_name = 'contribution_refund';
}
  end

  def down
    execute %Q{
    drop index if exists idx_contribution_refund_evt_uniq;
}
  end
end
