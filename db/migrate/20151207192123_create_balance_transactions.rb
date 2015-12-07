class CreateBalanceTransactions < ActiveRecord::Migration
  def change
    create_table :balance_transactions do |t|
      t.integer :project_id
      t.integer :contribution_id
      t.text :event_name, null: false
      t.integer :user_id, null: false

      t.timestamps
    end

    add_column :balance_transactions, :amount, :numeric, null: false

    add_index :balance_transactions, [:project_id, :event_name, :user_id], unique: true, name: 'event_project_uidx'
    add_index :balance_transactions, [:contribution_id, :event_name, :user_id], unique: true, name: 'event_contribution_uidx'
  end
end
