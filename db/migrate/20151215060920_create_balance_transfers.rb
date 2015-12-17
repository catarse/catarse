class CreateBalanceTransfers < ActiveRecord::Migration
  def up
    create_table :balance_transfers do |t|
      t.integer :user_id, null: false
      t.float :amount, null: false
      t.text :transfer_id, foreign_key: false

      t.timestamps
    end

    add_column :balance_transactions, :balance_transfer_id, :integer

    execute <<-SQL
ALTER TABLE public.balance_transfers
    ALTER COLUMN amount TYPE numeric;
    SQL
  end

  def down
    remove_column :balance_transactions, :balance_transfer_id, :integer
    drop_table :balance_transfers
  end
end
