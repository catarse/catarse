class AddAddressCountryToContributions < ActiveRecord::Migration
  def change
    add_column :contributions, :address_country, :text
  end
end
