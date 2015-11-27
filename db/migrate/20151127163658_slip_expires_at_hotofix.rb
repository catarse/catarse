class SlipExpiresAtHotofix < ActiveRecord::Migration
  def up
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
      LIMIT 3
    ) a;
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
