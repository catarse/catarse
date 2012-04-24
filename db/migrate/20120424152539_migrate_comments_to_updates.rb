class MigrateCommentsToUpdates < ActiveRecord::Migration
  def self.up
    execute <<SQL
    INSERT INTO updates (user_id, project_id, title, comment, comment_html, created_at, updated_at)
    SELECT user_id, commentable_id, title, comment, comment_html, created_at, updated_at
    FROM comments
    WHERE project_update;
SQL
  end

  def self.down
  end
end
