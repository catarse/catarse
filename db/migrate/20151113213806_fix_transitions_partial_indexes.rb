class FixTransitionsPartialIndexes < ActiveRecord::Migration
  def change
    execute <<-SQL
    DROP INDEX index_project_transitions_parent_most_recent;
    DROP INDEX index_flexible_project_transitions_parent_most_recent;
    CREATE INDEX ON project_transitions (project_id) WHERE most_recent;
    CREATE INDEX ON flexible_project_transitions (flexible_project_id) WHERE most_recent;
    SQL
  end
end
