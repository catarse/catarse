class CreateGatewayPayments < ActiveRecord::Migration
  def up
    create_table :gateway_payments do |t|
      t.integer :payment_id
      t.text :transaction_id, foreign_key: false
      t.json :gateway_data
      t.json :postbacks
      t.timestamp :last_sync_at

      t.timestamps
    end

    execute %Q{
    ALTER TABLE gateway_payments
        ALTER COLUMN gateway_data SET DATA TYPE jsonb,
        ALTER COLUMN postbacks SET DATA TYPE jsonb;
    }
  end

  def down
    drop_table :gateway_payments
  end
end
