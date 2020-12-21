class AddCountryIdToContributions < ActiveRecord::Migration[4.2]
  def change
    add_column :contributions, :country_id, :integer
  end
end
