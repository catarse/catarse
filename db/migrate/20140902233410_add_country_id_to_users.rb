class AddCountryIdToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :country_id, :integer
  end
end
