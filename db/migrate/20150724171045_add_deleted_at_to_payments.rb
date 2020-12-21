class AddDeletedAtToPayments < ActiveRecord::Migration[4.2]
  def change
    add_column :payments, :deleted_at, :timestamp
  end
end
