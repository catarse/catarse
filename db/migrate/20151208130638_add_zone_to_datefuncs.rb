class AddZoneToDatefuncs < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE OR REPLACE FUNCTION online_at(project projects) RETURNS timestamp without time zone
    LANGUAGE sql STABLE
    AS $$
        SELECT get_date_from_project_transitions(project.id, 'online');
    $$;
    SQL
  end

  def down
    execute <<-SQL
DROP FUNCTION online_at(project projects);
    SQL
  end
end
