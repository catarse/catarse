class AddAddressIdToUsers < ActiveRecord::Migration[4.2]
  def change
    add_reference :users, :address, index: true
  end
end
