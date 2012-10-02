class DropPaymentDetails < ActiveRecord::Migration
  def up
    drop_table :payment_details
  end

  def down
  end
end
