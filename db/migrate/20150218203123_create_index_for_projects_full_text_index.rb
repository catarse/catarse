class CreateIndexForProjectsFullTextIndex < ActiveRecord::Migration[4.2]
  def up
    execute "
    CREATE INDEX projects_full_text_index_ix ON projects USING GIN (full_text_index);
    "
  end

  def down
    execute "
    DROP INDEX projects_full_text_index_ix;
    "
  end
end
