class CreateSubscriptionPayments < ActiveRecord::Migration
  def change
    create_table :subscription_payments do |t|
      t.bigint :gateway_payment_id, null: false
      t.references :subscription, index: true, foreign_key: true, null: false
      t.text :status, null: false
      t.jsonb :gateway_data, null: false

      t.timestamps null: false
    end
  end
end
