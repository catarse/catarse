class CreatePaymentLogs < ActiveRecord::Migration
  def change
    create_table :payment_logs do |t|
      t.string :gateway_id, null: false, foreign_key: false
      t.json :data, null: false

      t.timestamps
    end
  end
end
