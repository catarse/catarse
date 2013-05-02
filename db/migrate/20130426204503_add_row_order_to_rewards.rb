class AddRowOrderToRewards < ActiveRecord::Migration
  def change
    add_column :rewards, :row_order, :integer
    Reward.update_all row_order: 0
  end
end
