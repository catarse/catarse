class FixTransferDate < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
CREATE OR REPLACE FUNCTION public.transfer_limit_date(bt balance_transfers)
 RETURNS timestamp without time zone
 LANGUAGE sql
AS $function$
        select
            (weekdays_from(10, zone_timestamp(bt.created_at)));
    $function$
    SQL
  end

  def down
    execute <<-SQL
CREATE OR REPLACE FUNCTION public.transfer_limit_date(bt balance_transfers)
 RETURNS timestamp without time zone
 LANGUAGE sql
AS $function$
        select
            zone_timestamp(weekdays_from(10, zone_timestamp(bt.created_at)));
    $function$
    SQL
  end
end
