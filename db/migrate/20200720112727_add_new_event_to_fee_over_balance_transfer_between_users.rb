class AddNewEventToFeeOverBalanceTransferBetweenUsers < ActiveRecord::Migration[4.2]
  def change
    add_index :balance_transactions, [:event_name, :balance_transaction_id, :user_id], where: "event_name = 'balance_transaction_fee'", name: 'balance_transaction_fee_etv_uidx', unique: true
  end
end
