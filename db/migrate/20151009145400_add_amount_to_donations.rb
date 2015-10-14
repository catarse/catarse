class AddAmountToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :amount, :integer
    add_reference :donations, :user, index: true
  end
end
