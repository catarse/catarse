class RenameUpdatesToProjectPosts < ActiveRecord::Migration
  def up
    execute <<-SQL
    ALTER TABLE "updates" RENAME TO project_posts;
    ALTER TABLE notifications RENAME update_id TO project_post_id;
    SQL
  end

  def down
    execute <<-SQL
    ALTER TABLE "project_posts" RENAME TO "updates";
    ALTER TABLE notifications RENAME project_post_id TO update_id;
    SQL
  end
end
