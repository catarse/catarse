class RemoveBooleanFieldsFromProjects < ActiveRecord::Migration
  def up
    remove_column :projects, :can_finish
    remove_column :projects, :finished
    remove_column :projects, :visible
    remove_column :projects, :rejected
    remove_column :projects, :successful
  end

  def down
    add_column :projects, :can_finish, :boolean, default: false
    add_column :projects, :finished, :boolean, default: false
    add_column :projects, :visible, :boolean, default: false
    add_column :projects, :rejected, :boolean, default: false
    add_column :projects, :successful, :boolean, default: false
  end
end
