class AddBatchIdToBalanceTransfers < ActiveRecord::Migration[6.1]
  def change
    add_column :balance_transfers, :batch_id, :string, :null => true
  end
end
