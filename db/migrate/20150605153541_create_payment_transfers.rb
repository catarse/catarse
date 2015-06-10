class CreatePaymentTransfers < ActiveRecord::Migration
  def change
    create_table :payment_transfers do |t|
      t.integer :user_id, null: false
      t.integer :payment_id, null: false
      t.text :transfer_id, null: false, foreign_key: false
      t.json :transfer_data

      t.timestamps
    end
  end
end
