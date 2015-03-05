class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.text     :state, null: false
      t.text     :key, null: false
      t.text     :gateway, null: false
      t.text     :gateway_id, foreign_key: false
      t.decimal  :gateway_fee
      t.json     :geteway_data
      t.text     :method, null: false
      t.decimal  :value, null: false
      t.integer  :installments, null: false, default: 1
      t.integer  :installment_value, null: false
      t.timestamps
    end
  end
end
