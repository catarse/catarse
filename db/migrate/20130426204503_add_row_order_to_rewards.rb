class AddRowOrderToRewards < ActiveRecord::Migration
  def change
    add_column :rewards, :row_order, :integer
    #placeholder value as ranked-model doesn't seem to like null values
    execute "UPDATE rewards SET row_order = rewards.minimum_value;"
  end
end
