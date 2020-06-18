class AddProjectAntecipationFee < ActiveRecord::Migration
  def change
    add_index :balance_transactions, [:event_name, :project_id, :balance_transfer_id], where: "event_name = 'project_antecipation_fee'", name: 'balance_project_antecipation_fee_evt_uniq', unique: true
  end
end
