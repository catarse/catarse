class RemoveCreditsFromUsers < ActiveRecord::Migration[4.2]
  def up
    remove_column :users, :credits
  end

  def down
    add_column :users, :credits, :numeric, default: 0
  end
end
