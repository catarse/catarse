class CreateShippingFees < ActiveRecord::Migration[4.2]
  def change
    create_table :shipping_fees do |t|
      t.references :reward, null: false
      t.text :destination
      t.decimal :value, precision: 8, scale: 2, null: false

      t.timestamps
    end
  end
end
