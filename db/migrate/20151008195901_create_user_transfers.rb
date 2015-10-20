class CreateUserTransfers < ActiveRecord::Migration
  def change
    create_table :user_transfers do |t|
      t.text :status, null: false
      t.integer :amount, null: false
      t.references :user, null: false
      t.json :transfer_data
      t.integer :gateway_id, foreign_key: false

      t.timestamps
    end
  end
end
