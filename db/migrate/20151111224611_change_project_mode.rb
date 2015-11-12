class ChangeProjectMode < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE OR REPLACE FUNCTION mode(project projects) RETURNS text
    LANGUAGE sql
    AS $$
        SELECT
          CASE WHEN EXISTS ( SELECT 1 FROM flexible_projects WHERE project_id = project.id ) THEN
            'flex'
          ELSE
            'aon'
          END;
      $$;

CREATE OR REPLACE FUNCTION state_order(project projects) RETURNS project_state_order
    LANGUAGE sql STABLE
    AS $$
SELECT
    CASE project.mode
    WHEN 'flex' THEN
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
    CREATE OR REPLACE FUNCTION mode(project projects) RETURNS text
    LANGUAGE sql
    AS $$
    SELECT
    CASE WHEN EXISTS ( SELECT 1 FROM flexible_projects WHERE project_id = project.id ) THEN
    'flexible'
    ELSE
    'all_or_nothing'
    END;
    $$;

    CREATE OR REPLACE FUNCTION state_order(project projects) RETURNS project_state_order
    LANGUAGE sql STABLE
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
end
