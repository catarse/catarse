class CreateElapsedTime < ActiveRecord::Migration
  def change
    execute <<-SQL
    CREATE OR REPLACE FUNCTION elapsed_time_interval(projects) RETURNS interval
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
            select (current_timestamp - (SELECT created_at FROM project_transitions pt WHERE pt.to_state = 'online' AND pt.most_recent= 't' AND pt.project_id = $1.id ))::interval
          $_$;

    CREATE OR REPLACE FUNCTION elapsed_time_json(projects) RETURNS json
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
            select public.interval_to_json($1.elapsed_time_interval)
        $_$;
    SQL
  end
end
