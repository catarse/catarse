class AddExclusiveToUpdates < ActiveRecord::Migration
  def change
    add_column :updates, :exclusive, :boolean, default: false
  end
end
