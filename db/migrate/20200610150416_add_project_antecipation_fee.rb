class AddProjectAntecipationFee < ActiveRecord::Migration
  def up
    execute %Q{
create unique index balance_project_antecipation_fee_evt_uniq
  on public.balance_transactions (event_name, project_id, balance_transfer_id)
  where event_name = 'project_antecipation_fee'::text;
}
  end

  def down
    execute %Q{
drop index if exists balance_project_antecipation_fee_evt_uniq;
}
  end
end
