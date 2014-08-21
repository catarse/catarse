class AddAddressCountryToUsers < ActiveRecord::Migration
  def change
    add_column :users, :address_country, :text
  end
end
