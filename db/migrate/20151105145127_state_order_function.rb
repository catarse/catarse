class StateOrderFunction < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE FUNCTION state_order(project projects)
RETURNS project_state_order
STABLE
LANGUAGE SQL
AS $$
SELECT
    CASE project.mode
    WHEN 'flexible' THEN
        (
        SELECT state_order
        FROM
        flexible_project_states ps
        WHERE
        ps.state = project.state
        )
    ELSE
        (
        SELECT state_order
        FROM
        project_states ps
        WHERE
        ps.state = project.state
        )
    END;
$$;
    SQL
  end

  def down
    execute <<-SQL
DROP FUNCTION state_order(projects);
    SQL
  end
end
