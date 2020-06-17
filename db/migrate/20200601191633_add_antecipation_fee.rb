class AddAntecipationFee < ActiveRecord::Migration
  def change
    add_column :projects, :antecipation_fee, :numeric, default: 0.025, null: false
    add_index :balance_transactions, [:event_name, :project_id, :contribution_id], where: "event_name = 'antecipation_fee'", name: 'balance_antecipation_fee_evt_uniq', unique: true
    add_index :balance_transactions, [:event_name, :project_id, :contribution_id], where: "event_name = 'contribution_payment'", name: 'balance_contribution_payment_evt_uniq', unique: true
  end
end
