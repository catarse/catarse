class AddUniqueIndexForContributionEventsOnBalanceTransactions < ActiveRecord::Migration
  def up
    execute %Q{
drop index if exists event_contribution_uidx;
drop index if exists event_project_uidx;

create unique index idx_catarse_contribution_fee_evt_uniq on balance_transactions (event_name, contribution_id) where event_name = 'catarse_contribution_fee';
create unique index idx_project_contribution_confirmed_after_evt_uniq on balance_transactions (event_name, contribution_id) where event_name = 'project_contribution_confirmed_after_finished';
}
  end

  def down
    execute %Q{
create unique index if not exists  event_contribution_uidx on balance_transactions(contribution_id,event_name,user_id);
create unique index if not exists event_project_uidx on balance_transactions(project_id,event_name,user_id);

drop index if exists idx_catarse_contribution_fee_evt_uniq;
drop index if exists idx_project_contribution_confirmed_after_evt_uniq;
}
  end
end
