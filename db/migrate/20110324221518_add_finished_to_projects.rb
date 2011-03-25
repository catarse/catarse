class AddFinishedToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :can_finish, :boolean, :default => false
    add_column :projects, :finished, :boolean, :default => false
    execute("UPDATE projects SET can_finish = false, finished = false")
  end

  def self.down
    remove_column :projects, :can_finish
    remove_column :projects, :finished
  end
end
