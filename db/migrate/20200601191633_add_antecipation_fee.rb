class AddAntecipationFee < ActiveRecord::Migration
  def up
    add_column :projects, :antecipation_fee, default: 0.025, null: false
    execute %Q{
create unique index balance_antecipation_fee_evt_uniq
  on public.balance_transactions (event_name, project_id, contribution_id)
  where event_name = 'antecipation_fee'::text;

create unique index balance_contribution_payment_evt_uniq
  on public.balance_transactions (event_name, project_id, contribution_id)
  where event_name = 'contribution_payment'::text;
}
  end

  def down
    remove_column :projects, :antecipation_fee
    execute %Q{
drop index if exists balance_antecipation_fee_evt_uniq;
drop index if exists balance_contribution_payment_evt_uniq;
}
  end
end
