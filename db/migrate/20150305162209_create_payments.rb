class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer  :contribution_id, null: false
      t.text     :state, null: false
      t.text     :key, null: false
      t.text     :gateway, null: false
      t.text     :gateway_id, foreign_key: false
      t.decimal  :gateway_fee
      t.json     :gateway_data
      t.text     :payment_method, null: false
      t.decimal  :value, null: false
      t.integer  :installments, null: false, default: 1
      t.decimal  :installment_value, null: false
      t.timestamp :paid_at
      t.timestamp :refused_at
      t.timestamp :pending_refund_at
      t.timestamp :refunded_at
      t.timestamps
    end
  end
end
