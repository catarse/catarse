class AdjustOnSlipExpiresAt < ActiveRecord::Migration
  def up
    execute <<-SQL
create or replace function slip_expires_at(payments) returns timestamp without time zone
  stable
  language sql
as
$$
SELECT weekdays_from(public.slip_expiration_weekdays(), public.zone_timestamp(coalesce(($1.gateway_data->>'boleto_expiration_date'::text)::timestamp, $1.created_at)))::date + 1 - '1 second'::interval;
$$;
    SQL
  end

  def down
    execute <<-SQL
create or replace function slip_expires_at(payments) returns timestamp without time zone
  stable
  language sql
as
$$
SELECT weekdays_from(public.slip_expiration_weekdays(), public.zone_timestamp($1.created_at))::date + 1 - '1 second'::interval;
$$;
    SQL
  end
end
