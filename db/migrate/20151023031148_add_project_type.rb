class AddProjectType < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE FUNCTION public.project_type(project projects) RETURNS text
      LANGUAGE plpgsql AS $$
        BEGIN
          IF NOT EXISTS ( SELECT 1 FROM flexible_projects WHERE project_id = project.id ) THEN
            RETURN 'all_or_nothing';
          ELSE
            RETURN 'flexible';
          END IF;
        END;
      $$;
    SQL
  end

  def down
    execute <<-SQL
      DROP FUNCTION public.project_type(project projects);
    SQL
  end
end
