class AddDeliverAtIntoRewards < ActiveRecord::Migration[4.2]
  def change
    add_column :rewards, :deliver_at, :datetime
  end
end
