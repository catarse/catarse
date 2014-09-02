class AddCountryIdToContributions < ActiveRecord::Migration
  def change
    add_column :contributions, :country_id, :integer
  end
end
