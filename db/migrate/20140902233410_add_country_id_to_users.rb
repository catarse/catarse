class AddCountryIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :country_id, :integer
  end
end
