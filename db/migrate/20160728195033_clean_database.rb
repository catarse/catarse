class CleanDatabase < ActiveRecord::Migration
  def change
    execute <<-SQL
  CREATE  OR REPLACE FUNCTION state_order(project_id integer) RETURNS project_state_order
      LANGUAGE sql STABLE
      AS $_$
      SELECT state_order
      FROM projects p
      JOIN project_states ps ON p.state = ps.state
      where p.id = $1;
  $_$;

   drop table flexible_project_transitions;
   drop table flexible_projects;
   drop table flexible_project_states;
   drop table project_budgets;
    SQL
  end
end
