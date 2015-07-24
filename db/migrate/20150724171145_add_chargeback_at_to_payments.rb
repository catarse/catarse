class AddChargebackAtToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :chargeback_at, :timestamp
  end
end
