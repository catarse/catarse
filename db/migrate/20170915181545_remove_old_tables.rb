class RemoveOldTables < ActiveRecord::Migration
  def change
    execute <<-SQL
      DROP TABLE IF EXISTS flexible_project_transitions ;

      DROP TABLE IF EXISTS flexible_projects ;
    SQL
  end
end
