class FixSlipExpiresAt < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
    CREATE OR REPLACE FUNCTION public.slip_expires_at(payments)
     RETURNS timestamp without time zone
     LANGUAGE sql
     STABLE
    AS $function$
    SELECT weekdays_from(public.slip_expiration_weekdays(), public.zone_timestamp($1.created_at))::date + 1 - '1 second'::interval;
    $function$
    SQL
  end
  def down
    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.slip_expires_at(payments)
       RETURNS timestamp without time zone
       LANGUAGE sql
       STABLE
      AS $function$
      SELECT weekdays_from(public.slip_expiration_weekdays(), public.zone_timestamp($1.created_at))
          $function$
    SQL
  end
end
