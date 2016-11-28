class AddSkipFinishToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :skip_finish, :boolean, default: false
  end
end
