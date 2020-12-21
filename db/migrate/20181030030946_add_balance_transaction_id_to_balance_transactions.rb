class AddBalanceTransactionIdToBalanceTransactions < ActiveRecord::Migration[4.2]
  def change
    add_column :balance_transactions, :balance_transaction_id, :integer, foreign_key: true
  end
end
