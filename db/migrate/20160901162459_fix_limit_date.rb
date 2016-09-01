class FixLimitDate < ActiveRecord::Migration
  def change
    execute <<-SQL
      CREATE OR REPLACE FUNCTION addbusinessdays(date, integer)
    RETURNS date AS
  $BODY$
  with alldates as (
    SELECT i,
    -- Check for negatives
    $1 + (i * case when $2 < 0 then -1 else 1 end) AS date
    -- NOTE we add 5 and x 2, to make sure the sequence has enough in it to cope with weekends/hols that get omitted later
    FROM generate_series(0,(abs($2) + 5)*2) i
  ),
  days as (
    select i, date, extract('dow' from date) as dow
    from alldates
  ),
  businessdays as (
    select i, date, d.dow from days d
    
    where d.dow between 1 and 5
    order by i
  )
  --select count(*) from businessdays where date between '2010-04-01' and '2010-04-07';
  -- now to add biz days to a date
  select date from businessdays where
          case when $2 > 0 then date >=$1 when $2 < 0 then date <=$1 else date =$1 end
    limit 1
    offset abs($2)
  $BODY$
    LANGUAGE 'sql' VOLATILE
    COST 100;




  CREATE OR REPLACE VIEW "1"."balance_transfers" AS 
   SELECT bt.id,
      bt.user_id,
      bt.project_id,
      bt.amount,
      bt.transfer_id,
      zone_timestamp(bt.created_at) AS created_at,
      zone_timestamp(addbusinessdays(bt.created_at::date, 10)) AS transfer_limit_date,
      current_state(bt.*) AS state
     FROM public.balance_transfers bt
    WHERE public.is_owner_or_admin(bt.user_id);
    SQL
  end
end
