class AdjustIntervalFunctionsIntoProject < ActiveRecord::Migration
  def up
    execute <<-SQL
SET statement_timeout TO 0;
    SQL

    execute <<-SQL
CREATE FUNCTION public.interval_to_json(interval) RETURNS json
    LANGUAGE sql IMMUTABLE SECURITY DEFINER
    AS $_$
            select (
              case
              when $1 <= '0 seconds'::interval then
                json_build_object('total', 0, 'unit', 'seconds')
              else
                case
                when $1 >= '1 day'::interval then
                  json_build_object('total', extract(day from $1), 'unit', 'days')
                when $1 >= '1 hour'::interval and $1 < '24 hours'::interval then
                  json_build_object('total', extract(hour from $1), 'unit', 'hours')
                when $1 >= '1 minute'::interval and $1 < '60 minutes'::interval then
                  json_build_object('total', extract(minutes from $1), 'unit', 'minutes')
                when $1 < '60 seconds'::interval then
                  json_build_object('total', extract(seconds from $1), 'unit', 'seconds')
                 else json_build_object('total', 0, 'unit', 'seconds') end
              end
            )
        $_$;

CREATE OR REPLACE FUNCTION public.remaining_time_json(projects) RETURNS json
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
            select public.interval_to_json($1.remaining_time_interval)
        $_$;

CREATE OR REPLACE FUNCTION public.elapsed_time_json(projects) RETURNS json
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
            select public.interval_to_json(least(now(), $1.expires_at) - $1.online_date)
        $_$;
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
