class RenameUpdatesToProjectPosts < ActiveRecord::Migration
  def change
    execute <<-SQL
    ALTER TABLE "updates" RENAME TO project_posts;
    ALTER TABLE notifications RENAME update_id TO project_post_id;
    SQL
  end
end
