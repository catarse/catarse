class SomeFixesOnPayments < ActiveRecord::Migration
  disable_ddl_transaction!
  def up
    execute %{
CREATE OR REPLACE FUNCTION public.zone_timestamp(timestamp without time zone)
 RETURNS timestamp without time zone
 LANGUAGE sql
 IMMUTABLE SECURITY DEFINER
AS $function$
    -- hardcoded timezone to use immutable function / index
        SELECT $1::timestamptz AT TIME ZONE 'America/Sao_Paulo';
      $function$
;
    }
    execute %{
CREATE INDEX CONCURRENTLY payment_created_at_z_uidx ON payments(public.zone_timestamp(created_at));
    }
  end

  def down
    execute %{
CREATE OR REPLACE FUNCTION public.zone_timestamp(timestamp without time zone)
 RETURNS timestamp without time zone
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
        SELECT $1::timestamptz AT TIME ZONE public.settings('timezone'::text);
      $function$
;

DROP INDEX payment_created_at_z_uidx;
    }
  end
end
