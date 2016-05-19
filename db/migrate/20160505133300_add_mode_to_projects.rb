class AddModeToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :mode, :text, null: false, default: 'aon'
  end
end
