class AddSubscribedToProjectPostsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :subscribed_to_project_posts, :boolean, default: true
  end
end
