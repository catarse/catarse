class AddAddressIdToContributions < ActiveRecord::Migration[4.2]
  def change
    add_reference :contributions, :address, index: true
  end
end
