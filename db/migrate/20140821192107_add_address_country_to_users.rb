class AddAddressCountryToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :address_country, :text
  end
end
