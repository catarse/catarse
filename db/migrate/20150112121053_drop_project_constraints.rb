class DropProjectConstraints < ActiveRecord::Migration
  def change
    execute <<-SQL
      ALTER TABLE projects DROP CONSTRAINT projects_about_not_blank;
      ALTER TABLE projects DROP CONSTRAINT projects_headline_not_blank;
      ALTER TABLE projects DROP CONSTRAINT projects_headline_length_within;
    SQL
  end
end
