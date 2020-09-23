class ProjectsUpdateFullTextIndexWhenStateChanges < ActiveRecord::Migration
  def up
    execute <<-SQL

    DROP TRIGGER update_full_text_index ON projects;

    CREATE TRIGGER update_full_text_index 
    BEFORE INSERT OR UPDATE OF name, permalink, headline, state
    ON projects
    FOR EACH ROW
    EXECUTE PROCEDURE update_full_text_index();

    SQL
  end

  def down
    execute <<-SQL

    DROP TRIGGER update_full_text_index ON projects;

    CREATE TRIGGER update_full_text_index 
    BEFORE INSERT OR UPDATE OF name, permalink, headline
    ON projects
    FOR EACH ROW
    EXECUTE PROCEDURE update_full_text_index();

    SQL
  end
end
