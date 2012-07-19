class RemoveOrderFromProjects < ActiveRecord::Migration
  def up
    remove_column :projects, :order
  end

  def down
    add_column :projects, :order, :integer
  end
end
