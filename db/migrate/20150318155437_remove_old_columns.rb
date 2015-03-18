class RemoveOldColumns < ActiveRecord::Migration
  def change
    remove_column :projects, :about
    remove_column :users, :bio
    remove_column :users, :image_url
    remove_column :users, :project_updates
    remove_column :users, :about
    remove_column :project_posts, :comment
  end
end
