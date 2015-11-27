class SlipExpiresAtHotofix < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE OR REPLACE FUNCTION public.slip_expiration_weekdays()
 RETURNS int
 LANGUAGE sql
 STABLE
AS $function$
    SELECT 2;
    $function$;

CREATE OR REPLACE FUNCTION public.weekdays_from(weekdays int, from_ts timestamp)
 RETURNS timestamp without time zone
 LANGUAGE sql
 STABLE
AS $function$
    SELECT max(day) FROM (
      SELECT day
      FROM generate_series(from_ts, from_ts + '1 year'::interval, '1 day') day
      WHERE extract(dow from day) not in (0,1)
      ORDER BY day
      LIMIT (weekdays + 1)
    ) a;
    $function$;

CREATE OR REPLACE FUNCTION public.slip_expires_at(payments)
 RETURNS timestamp without time zone
 LANGUAGE sql
 STABLE
AS $function$
SELECT weekdays_from(public.slip_expiration_weekdays(), $1.created_at);
    $function$;
    SQL
  end

  def down
    execute <<-SQL
CREATE OR REPLACE FUNCTION public.slip_expires_at(payments)
 RETURNS timestamp without time zone
 LANGUAGE sql
 STABLE
AS $function$
    SELECT max(day) FROM (
      SELECT day
      FROM generate_series($1.created_at, $1.created_at + '1 month'::interval, '1 day') day
      WHERE extract(dow from day) not in (0,1)
      ORDER BY day
      LIMIT 2
    ) a;
    $function$;
    SQL
  end
end
