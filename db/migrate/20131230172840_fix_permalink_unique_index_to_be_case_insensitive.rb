class FixPermalinkUniqueIndexToBeCaseInsensitive < ActiveRecord::Migration
  def change
    remove_index :projects, :permalink
    execute "CREATE UNIQUE INDEX index_projects_on_permalink ON projects (lower(permalink))"
  end
end
