class AddMetadataToBalanceTransactions < ActiveRecord::Migration
  def change
    add_column :balance_transactions, :metadata, :jsonb
  end
end
