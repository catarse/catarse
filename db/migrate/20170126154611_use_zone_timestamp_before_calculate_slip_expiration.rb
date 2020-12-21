class UseZoneTimestampBeforeCalculateSlipExpiration < ActiveRecord::Migration[4.2]
  def up
    execute %Q{
CREATE OR REPLACE FUNCTION public.slip_expires_at(payments)
 RETURNS timestamp without time zone
 LANGUAGE sql
 STABLE
AS $function$
SELECT weekdays_from(public.slip_expiration_weekdays(), public.zone_timestamp($1.created_at));
    $function$
;
}
  end

  def down
    execute %Q{
CREATE OR REPLACE FUNCTION public.slip_expires_at(payments)
 RETURNS timestamp without time zone
 LANGUAGE sql
 STABLE
AS $function$
SELECT weekdays_from(public.slip_expiration_weekdays(), $1.created_at);
    $function$
;
}
  end
end
