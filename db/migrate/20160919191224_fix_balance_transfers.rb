class FixBalanceTransfers < ActiveRecord::Migration
  def change
    execute <<-SQL
    CREATE OR REPLACE VIEW "1"."balance_transfers" AS 
   SELECT bt.id,
      bt.user_id,
      bt.project_id,
      bt.amount,
      bt.transfer_id,
      zone_timestamp(bt.created_at) AS created_at,
      zone_timestamp(weekdays_from(10, bt.created_at)) AS transfer_limit_date,
      current_state(bt.*) AS state
     FROM public.balance_transfers bt
    WHERE public.is_owner_or_admin(bt.user_id);


    DROP FUNCTION addbusinessdays(date, integer)
    SQL
  end
end
