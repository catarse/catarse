class AddCommonIdToProjectPosts < ActiveRecord::Migration
  def change
    add_column :project_posts, :common_id, :uuid, unique: true, foreign_key: false
  end
end
