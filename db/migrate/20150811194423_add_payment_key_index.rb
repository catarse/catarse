class AddPaymentKeyIndex < ActiveRecord::Migration
  def change
    add_index :payments, :key, unique: true
  end
end
