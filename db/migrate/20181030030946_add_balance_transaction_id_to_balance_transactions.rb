class AddBalanceTransactionIdToBalanceTransactions < ActiveRecord::Migration
  def change
    add_column :balance_transactions, :balance_transaction_id, :integer, foreign_key: true
  end
end
