class AddToUserFromUserOnBalanceTransactions < ActiveRecord::Migration[4.2]
  def change
    add_column :balance_transactions, :from_user_id, :integer, foreign_key: false
    add_column :balance_transactions, :to_user_id, :integer, foreign_key: false

    add_foreign_key :balance_transactions, :users, column: :to_user_id
    add_foreign_key :balance_transactions, :users, column: :from_user_id
  end
end
