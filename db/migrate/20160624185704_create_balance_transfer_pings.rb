class CreateBalanceTransferPings < ActiveRecord::Migration
  def up
    create_table :balance_transfer_pings do |t|
      t.references :balance_transfer, index: true
      t.text :state, null: false, default: 'pending'
      t.text :transfer_id, foreign_key: false
      t.float :amount, null: false

      t.timestamps
    end

    add_column :balance_transfer_pings, :metadata, :jsonb, null: false, default: '{}'
    add_column :balance_transactions, :balance_transfer_ping_id, :integer

    execute <<-SQL
      ALTER TABLE public.balance_transfer_pings
      ALTER COLUMN amount TYPE numeric;
    SQL
  end

  def down
    remove_column :balance_transactions, :balance_transfer_ping_id, :integer
    drop_table :balance_transfer_pings
  end

end
