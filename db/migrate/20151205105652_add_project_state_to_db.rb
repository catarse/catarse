class AddProjectStateToDb < ActiveRecord::Migration
  def up
    execute <<-SQL
ALTER TABLE projects
    RENAME COLUMN state TO old_state;
CREATE OR REPLACE FUNCTION public.state(project public.projects) RETURNS text
    STABLE LANGUAGE sql
    AS $$
        SELECT COALESCE((
            CASE WHEN project.mode = 'flex' THEN
                (SELECT to_state
                FROM public.flexible_project_transitions
                WHERE most_recent 
                AND flexible_project_id = (
                    SELECT fp.id 
                    FROM public.flexible_projects fp
                    WHERE fp.project_id = project.id
                ) ORDER BY sort_key DESC LIMIT 1)
            ELSE
                (SELECT to_state
                FROM public.project_transitions
                WHERE most_recent and project_id = project.id
                ORDER BY sort_key DESC LIMIT 1)
            END), 'draft')
    $$;
    SQL
  end

  def down
    execute <<-SQL
DROP FUNCTION public.state(project public.projects);
ALTER TABLE projects
    RENAME COLUMN old_state TO state;
    SQL
  end
end
