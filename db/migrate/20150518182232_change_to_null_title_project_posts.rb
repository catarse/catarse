class ChangeToNullTitleProjectPosts < ActiveRecord::Migration[4.2]
  def change
    change_column_null :project_posts, :title, false
  end
end
