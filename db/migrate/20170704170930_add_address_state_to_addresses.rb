class AddAddressStateToAddresses < ActiveRecord::Migration
  def change
    add_column :addresses, :address_state, :text
  end
end
