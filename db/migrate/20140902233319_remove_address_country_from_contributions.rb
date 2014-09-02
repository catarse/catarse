class RemoveAddressCountryFromContributions < ActiveRecord::Migration
  def change
    remove_column :contributions, :address_country, :text
  end
end
