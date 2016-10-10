class CreateGatewayBalanceOperations < ActiveRecord::Migration
  def change
    create_table :gateway_balance_operations do |t|
      t.integer :operation_id, null: false, index: true, foreign_key: false
      t.json :operation_data
      t.timestamps
    end

    execute %Q{
    alter table gateway_balance_operations
    alter column created_at set default now(),
    alter column operation_data type jsonb USING operation_data::jsonb;
    }
  end
end
