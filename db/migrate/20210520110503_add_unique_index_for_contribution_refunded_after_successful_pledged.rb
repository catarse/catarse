class AddUniqueIndexForContributionRefundedAfterSuccessfulPledged < ActiveRecord::Migration[6.1]
  def up
    execute %Q{
      create unique index uidx_contrib_refunded_after_success_project on balance_transactions (event_name, contribution_id) where event_name = 'contribution_refunded_after_successful_pledged';
    }
  end

  def down
    execute %Q{
      drop index if exists uidx_contrib_refunded_after_success_project;
    }
  end
end