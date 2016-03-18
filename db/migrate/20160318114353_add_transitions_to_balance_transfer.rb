class AddTransitionsToBalanceTransfer < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE OR REPLACE FUNCTION public.current_state(bt public.balance_transfers) RETURNS text
    STABLE LANGUAGE sql
    AS $$
        SELECT COALESCE((SELECT btt.to_state FROM public.balance_transfer_transitions btt
        WHERE btt.balance_transfer_id = bt.id AND btt.most_recent LIMIT 1), 'pending');
    $$;

CREATE OR REPLACE VIEW "1".balance_transfers AS
 SELECT bt.id,
    bt.user_id,
    bt.project_id,
    bt.amount,
    bt.transfer_id,
    public.zone_timestamp(bt.created_at) AS created_at,
    public.zone_timestamp(
        (
            (bt.created_at + '10 days'::interval) + 
            (
                (select count(1) from (
                    select
                       generate_series(bt.created_at::date, (bt.created_at + '10 days'::interval), '1 day') as series
                    ) gs where extract(dow from gs.series) in (0,1)
                ) || ' days'
            )::interval
        )
    ) as transfer_limit_date,
    bt.current_state AS state
   FROM public.balance_transfers bt
  WHERE public.is_owner_or_admin(bt.user_id);

GRANT SELECT ON public.balance_transfer_transitions TO web_user, admin;
GRANT SELECT ON "1".balance_transfer_transitions TO web_user, admin;
    SQL
  end

  def down
    execute <<-SQL
CREATE OR REPLACE VIEW "1".balance_transfers AS
 SELECT bt.id,
    bt.user_id,
    bt.project_id,
    bt.amount,
    bt.transfer_id,
    public.zone_timestamp(bt.created_at) AS created_at,
    public.zone_timestamp(
        (
            (bt.created_at + '10 days'::interval) + 
            (
                (select count(1) from (
                    select
                       generate_series(bt.created_at::date, (bt.created_at + '10 days'::interval), '1 day') as series
                    ) gs where extract(dow from gs.series) in (0,1)
                ) || ' days'
            )::interval
        )
    ) as transfer_limit_date,
    'pending'::text AS state
   FROM public.balance_transfers bt
  WHERE public.is_owner_or_admin(bt.user_id);

DROP FUNCTION public.current_state(bt public.balance_transfers);
    SQL
  end
end
