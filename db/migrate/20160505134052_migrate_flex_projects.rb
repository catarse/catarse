class MigrateFlexProjects < ActiveRecord::Migration
  def change
    execute <<-SQL
      UPDATE projects p SET mode = 'flex', state = (SELECT state from flexible_projects fp WHERE project_id = p.id) WHERE EXISTS (SELECT project_id from flexible_projects fp WHERE project_id = p.id);
      INSERT INTO project_transitions(to_state, metadata, sort_key, project_id, most_recent, created_at, updated_at) 
        SELECT to_state, metadata, sort_key, (SELECT project_id from flexible_projects fp where fp.id = flexible_project_id), most_recent, created_at, updated_at from flexible_project_transitions WHERE NOT EXISTS(SELECT * from project_transitions WHERE project_id = (SELECT project_id from flexible_projects fp where fp.id = flexible_project_id));
    SQL
  end
end
