class AddIndexesOnPaymentLogs < ActiveRecord::Migration[4.2]
  def change
    add_index :payment_logs, :gateway_id, unique: true
  end
end
