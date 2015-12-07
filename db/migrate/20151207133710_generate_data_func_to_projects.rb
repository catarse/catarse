class GenerateDataFuncToProjects < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE OR REPLACE VIEW "1".project_transitions AS
    SELECT
        project_id,
        to_state as state,
        metadata,
        most_recent,
        created_at
    FROM project_transitions
    UNION ALL
    SELECT
        fp.project_id,
        fpt.to_state as state,
        fpt.metadata,
        fpt.most_recent,
        fpt.created_at
    FROM flexible_project_transitions fpt
    JOIN flexible_projects fp on fpt.flexible_project_id = fp.id;

GRANT select ON "1".project_transitions TO admin;

CREATE OR REPLACE FUNCTION get_date_from_project_transitions(project_id integer, state text) RETURNS timestamp without time zone
    LANGUAGE sql STABLE
    AS $$
        SELECT created_at
        FROM "1".project_transitions
        WHERE state = $2
        AND project_id = $1
    $$;

CREATE OR REPLACE FUNCTION in_analysis_at(project projects) RETURNS timestamp without time zone
    LANGUAGE sql STABLE
    AS $$
        SELECT get_date_from_project_transitions(project.id, 'in_analysis');
    $$;

CREATE OR REPLACE FUNCTION approved_at(project projects) RETURNS timestamp without time zone
    LANGUAGE sql STABLE
    AS $$
        SELECT get_date_from_project_transitions(project.id, 'approved');
    $$;

CREATE OR REPLACE FUNCTION waiting_funds_at(project projects) RETURNS timestamp without time zone
    LANGUAGE sql STABLE
    AS $$
        SELECT get_date_from_project_transitions(project.id, 'waiting_funds');
    $$;

CREATE OR REPLACE FUNCTION successful_at(project projects) RETURNS timestamp without time zone
    LANGUAGE sql STABLE
    AS $$
        SELECT get_date_from_project_transitions(project.id, 'successful');
    $$;

CREATE OR REPLACE FUNCTION failed_at(project projects) RETURNS timestamp without time zone
    LANGUAGE sql STABLE
    AS $$
        SELECT get_date_from_project_transitions(project.id, 'failed');
    $$;

CREATE OR REPLACE FUNCTION deleted_at(project projects) RETURNS timestamp without time zone
    LANGUAGE sql STABLE
    AS $$
        SELECT get_date_from_project_transitions(project.id, 'deleted');
    $$;
    SQL
  end

  def down
    execute <<-SQL
DROP VIEW "1".project_transitions;
DROP FUNCTION in_analysis_at(project projects);
DROP FUNCTION approved_at(project projects);
DROP FUNCTION waiting_funds_at(project projects);
DROP FUNCTION successful_at(project projects);
DROP FUNCTION failed_at(project projects);
DROP FUNCTION deleted_at(project projects);
    SQL
  end
end
