class AdjustIsPublishedOnProjectToSupportFlexible < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE OR REPLACE FUNCTION is_expired(projects) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
SELECT COALESCE(current_timestamp > $1.expires_at, false);
          $_$;

CREATE OR REPLACE FUNCTION open_for_contributions(projects) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
            SELECT (not $1.is_expired AND COALESCE(fp.state, $1.state) = 'online')
FROM projects p
LEFT JOIN flexible_projects fp on fp.project_id = $1.id
WHERE p.id = $1.id;
          $_$;


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
        ps.state = fp.state
        )
    ELSE
        (
        SELECT state_order
        FROM
        project_states ps
        WHERE
        ps.state = project.state
        )
    END
FROM projects p 
LEFT JOIN flexible_projects fp on fp.project_id = $1.id
WHERE p.id = $1.id;
$$;

CREATE OR REPLACE FUNCTION is_published(projects) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
          select $1.state_order >= 'published'::project_state_order;
        $_$;

DROP FUNCTION published_states();
    SQL
  end

  def down
    execute <<-SQL
CREATE OR REPLACE FUNCTION is_expired(projects) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
            SELECT (current_timestamp > $1.expires_at);
          $_$;

CREATE OR REPLACE FUNCTION open_for_contributions(projects) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
            SELECT (not $1.is_expired AND $1.state = 'online')
          $_$;

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

CREATE FUNCTION published_states() RETURNS text[]
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
            SELECT '{"online", "waiting_funds", "failed", "successful"}'::text[];
          $$;

CREATE OR REPLACE FUNCTION is_published(projects) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
          select $1.state = ANY(public.published_states());
        $_$;
    SQL

  end
end
