class ChangeToNullTitleProjectPosts < ActiveRecord::Migration
  def change
    change_column_null :project_posts, :title, false
  end
end
