class AddUniqueIndexesOnBalanceEvents < ActiveRecord::Migration
  def up
    execute %Q{
create unique index balance_error_evt_uniq on balance_transactions(event_name, balance_transfer_id)
    where event_name = 'balance_transfer_error';

create unique index successful_project_pledged_evt_uniq on balance_transactions(event_name, project_id)
    where event_name = 'successful_project_pledged';

create unique index catarse_project_service_fee_evt_uniq on balance_transactions(event_name, project_id)
    where event_name = 'catarse_project_service_fee';

create unique index irrf_tax_project_evt_uniq on balance_transactions(event_name, project_id)
    where event_name = 'irrf_tax_project';

}
  end
  def down
    execute %Q{
drop index balance_error_evt_uniq;
drop index successful_project_pledged_evt_uniq;
drop index catarse_project_service_fee_evt_uniq;
drop index irrf_tax_project_evt_uniq;
}
  end
end
