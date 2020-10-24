class FixWeekdaysFromFunction < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL
    CREATE OR REPLACE FUNCTION public.weekdays_from(weekdays integer, from_ts timestamp without time zone)
     RETURNS timestamp without time zone
     LANGUAGE sql
     STABLE
    AS $function$
            SELECT day FROM (
              SELECT day
              FROM generate_series(from_ts + '1 day'::interval, from_ts + '1 year'::interval, '1 day') day
              WHERE extract(dow from day) not in (0,6)
              ORDER BY day
            ) a LIMIT 1 OFFSET (weekdays - 1);
            $function$
    SQL
  end
end
