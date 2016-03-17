class CreateBalanceTransferTransitions < ActiveRecord::Migration
  def change
    create_table :balance_transfer_transitions do |t|
      t.string :to_state, null: false
      t.json :metadata, default: "{}"
      t.integer :sort_key, null: false
      t.integer :balance_transfer_id, null: false
      t.boolean :most_recent, null: false
      t.timestamps null: false
    end

    add_index(:balance_transfer_transitions,
              [:balance_transfer_id, :sort_key],
              unique: true,
              name: "index_balance_transfer_transitions_parent_sort")
    add_index(:balance_transfer_transitions,
              [:balance_transfer_id, :most_recent],
              unique: true,
              where: 'most_recent',
              name: "index_balance_transfer_transitions_parent_most_recent")
  end
end
