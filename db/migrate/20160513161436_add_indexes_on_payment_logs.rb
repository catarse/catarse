class AddIndexesOnPaymentLogs < ActiveRecord::Migration
  def change
    add_index :payment_logs, :gateway_id, unique: true
  end
end
