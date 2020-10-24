class AddChargebackAtToPayments < ActiveRecord::Migration[4.2]
  def change
    add_column :payments, :chargeback_at, :timestamp
  end
end
