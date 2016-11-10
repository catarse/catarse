class AddMoreColumnsToGatewayPayments < ActiveRecord::Migration
  def change
    add_column :gateway_payments, :events, :jsonb
    add_column :gateway_payments, :operations, :jsonb
  end
end
