class CreateGatewayPayables < ActiveRecord::Migration
  def change
    create_table :gateway_payables do |t|
      t.references :payment, index: true, foreign_key: true, null: false
      t.string :gateway_id, foreign_key: false, null: false, unique: true
      t.string :transaction_id, foreign_key: false, null: false
      t.decimal :fee, precision: 10, scale: 2, null: false
      t.jsonb :data, default: '{}'

      t.timestamps null: false
    end
  end
end
