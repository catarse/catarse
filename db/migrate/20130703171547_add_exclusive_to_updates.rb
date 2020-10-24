class AddExclusiveToUpdates < ActiveRecord::Migration[4.2]
  def change
    add_column :updates, :exclusive, :boolean, default: false
  end
end
