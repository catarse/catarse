class RemoveAddressCountryFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :address_country, :text
  end
end
