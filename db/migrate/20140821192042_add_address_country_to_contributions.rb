class AddAddressCountryToContributions < ActiveRecord::Migration[4.2]
  def change
    add_column :contributions, :address_country, :text
  end
end
