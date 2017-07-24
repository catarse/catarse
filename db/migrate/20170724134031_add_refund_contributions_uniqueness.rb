class AddRefundContributionsUniqueness < ActiveRecord::Migration
  def up
    execute %Q{
create unique index refund_contributions_evt_uniq on balance_transactions(event_name, project_id)
    where event_name = 'refund_contributions';
}
  end

  def down
    execute %Q{
drop index refund_contributions_evt_uniq;
}
  end
end
