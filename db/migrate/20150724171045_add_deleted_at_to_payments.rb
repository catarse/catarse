class AddDeletedAtToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :deleted_at, :timestamp
  end
end
