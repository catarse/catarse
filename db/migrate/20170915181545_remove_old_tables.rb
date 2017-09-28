class RemoveOldTables < ActiveRecord::Migration
  def change
    execute <<-SQL
      DROP VIEW  IF EXISTS flexible_project_transitions ;

      DROP VIEW  IF EXISTS flexible_projects ;
    SQL
  end
end
