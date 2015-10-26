class AddProjectType < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE FUNCTION public.project_type(project projects) RETURNS text
      LANGUAGE sql AS $$
        SELECT
          CASE WHEN EXISTS ( SELECT 1 FROM flexible_projects WHERE project_id = project.id ) THEN
            'flexible';
          ELSE
            'all_or_nothing';
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
