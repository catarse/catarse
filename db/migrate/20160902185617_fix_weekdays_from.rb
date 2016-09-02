class FixWeekdaysFrom < ActiveRecord::Migration
  def change
    execute <<-SQL
    CREATE OR REPLACE FUNCTION public.weekdays_from(weekdays int, from_ts timestamp)
     RETURNS timestamp without time zone
     LANGUAGE sql
     STABLE
    AS $function$
        SELECT max(day) FROM (
          SELECT day
          FROM generate_series(from_ts, from_ts + '1 year'::interval, '1 day') day
          WHERE extract(dow from day) not in (0,6)
          ORDER BY day
          LIMIT (weekdays + 1)
        ) a;
        $function$;
    SQL
  end
end
