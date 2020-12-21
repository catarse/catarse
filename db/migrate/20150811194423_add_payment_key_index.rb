class AddPaymentKeyIndex < ActiveRecord::Migration[4.2]
  def change
    add_index :payments, :key, unique: true
  end
end
