class CreatePixExpiresAtFunction < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.pix_expiration_weekdays()
      RETURNS int
      LANGUAGE sql
      STABLE
      AS $function$
          SELECT 2;
          $function$;

      CREATE OR REPLACE FUNCTION public.pix_expires_at(payments)
      RETURNS timestamp without time zone
      LANGUAGE sql
      STABLE
      AS $function$
      SELECT weekdays_from(public.pix_expiration_weekdays(), public.zone_timestamp(coalesce(($1.gateway_data->>'boleto_expiration_date'::text)::timestamp, $1.created_at)))::date + 1 - '1 second'::interval;
          $function$;
    SQL
  end

  def down
    execute <<-SQL
    DROP FUNCTION pix_expires_at(public.payments);
    SQL
  end
end
