class CleanDatabase < ActiveRecord::Migration
  def change
    execute <<-SQL

  CREATE  OR REPLACE FUNCTION state_order(project_id integer) RETURNS project_state_order
      LANGUAGE sql STABLE
      AS $_$
  SELECT
  CASE p.mode
  WHEN 'flex' THEN
      (
      SELECT state_order
      FROM
      public.project_states ps
      WHERE
      ps.state = p.state
      )
  ELSE
      (
      SELECT state_order
      FROM
      public.project_states ps
      WHERE
      ps.state = p.state
      )
  END
  FROM public.projects p
  WHERE p.id = $1;
  $_$;



   drop table flexible_project_transitions;
   drop table flexible_projects;
   drop table flexible_project_states;
   drop table project_budgets;
    SQL
  end
end
