class FixesForMigration < ActiveRecord::Migration
  def up
    execute %{
CREATE OR REPLACE FUNCTION remaining_time_json(projects) RETURNS json
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
            select public.interval_to_json(public.remaining_time_interval($1))
        $_$;
    }
  end

  def down
    execute %{
CREATE OR REPLACE FUNCTION remaining_time_json(projects) RETURNS json
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
            select public.interval_to_json($1.remaining_time_interval)
        $_$;
    }
  end
end
