class AddAddressIdToContributions < ActiveRecord::Migration
  def change
    add_reference :contributions, :address, index: true
  end
end
