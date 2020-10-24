class AddAmountToDonations < ActiveRecord::Migration[4.2]
  def change
    add_column :donations, :amount, :integer
    add_reference :donations, :user, index: true
  end
end
