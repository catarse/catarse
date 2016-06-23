class AdjustLimitDate < ActiveRecord::Migration
  def up
    execute %{
CREATE OR REPLACE VIEW "1"."balance_transfers" AS 
 SELECT bt.id,
    bt.user_id,
    bt.project_id,
    bt.amount,
    bt.transfer_id,
    zone_timestamp(bt.created_at) AS created_at,
    zone_timestamp(((bt.created_at + '10 days'::interval) + ((( SELECT count(1) AS count
           FROM ( SELECT generate_series(((bt.created_at)::date)::timestamp without time zone, (bt.created_at + '10 days'::interval), '1 day'::interval) AS series) gs
          WHERE (date_part('dow'::text, gs.series) = ANY (ARRAY[(0)::double precision, (6)::double precision]))) || ' days'::text))::interval)) AS transfer_limit_date,
    current_state(bt.*) AS state
   FROM public.balance_transfers bt
  WHERE public.is_owner_or_admin(bt.user_id);
    }
  end

  def down
    execute %{
CREATE OR REPLACE VIEW "1"."balance_transfers" AS 
 SELECT bt.id,
    bt.user_id,
    bt.project_id,
    bt.amount,
    bt.transfer_id,
    zone_timestamp(bt.created_at) AS created_at,
    zone_timestamp(((bt.created_at + '10 days'::interval) + ((( SELECT count(1) AS count
           FROM ( SELECT generate_series(((bt.created_at)::date)::timestamp without time zone, (bt.created_at + '10 days'::interval), '1 day'::interval) AS series) gs
          WHERE (date_part('dow'::text, gs.series) = ANY (ARRAY[(0)::double precision, (1)::double precision]))) || ' days'::text))::interval)) AS transfer_limit_date,
    current_state(bt.*) AS state
   FROM public.balance_transfers bt
  WHERE public.is_owner_or_admin(bt.user_id);
    }
  end
end
