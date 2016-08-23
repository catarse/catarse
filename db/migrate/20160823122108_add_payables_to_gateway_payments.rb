class AddPayablesToGatewayPayments < ActiveRecord::Migration
  def up
    execute %Q{
    ALTER TABLE gateway_payments
        ADD COLUMN payables JSONB;
    }
  end

  def down
    remove_column :gateway_payments, :payables
  end
end
