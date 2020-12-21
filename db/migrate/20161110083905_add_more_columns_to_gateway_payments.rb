class AddMoreColumnsToGatewayPayments < ActiveRecord::Migration[4.2]
  def change
    add_column :gateway_payments, :events, :jsonb
    add_column :gateway_payments, :operations, :jsonb
  end
end
