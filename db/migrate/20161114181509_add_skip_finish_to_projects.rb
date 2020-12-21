class AddSkipFinishToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :skip_finish, :boolean, default: false
  end
end
