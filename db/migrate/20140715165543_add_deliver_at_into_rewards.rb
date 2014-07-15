class AddDeliverAtIntoRewards < ActiveRecord::Migration
  def change
    add_column :rewards, :deliver_at, :datetime
  end
end
