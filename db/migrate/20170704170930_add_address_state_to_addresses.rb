class AddAddressStateToAddresses < ActiveRecord::Migration[4.2]
  def change
    add_column :addresses, :address_state, :text
  end
end
