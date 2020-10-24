class AddMetadataToBalanceTransactions < ActiveRecord::Migration[4.2]
  def change
    add_column :balance_transactions, :metadata, :jsonb
  end
end
