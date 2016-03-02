class AddProjectIdToBalanceTransfers < ActiveRecord::Migration
   def up
    add_column :balance_transfers, :project_id, :integer

    execute <<-SQL
DROP VIEW "1".balance_transfers;

CREATE VIEW "1".balance_transfers AS
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

GRANT SELECT ON "1".balance_transfers TO admin, web_user;
    SQL
  end

  def down
    execute <<-SQL
DROP VIEW "1".balance_transfers;

CREATE VIEW "1".balance_transfers AS
 SELECT bt.id,
    bt.user_id,
    bt.amount,
    bt.transfer_id,
    public.zone_timestamp(bt.created_at) AS created_at,
    'pending'::text AS state
   FROM public.balance_transfers bt
  WHERE public.is_owner_or_admin(bt.user_id);
GRANT SELECT ON "1".balance_transfers TO admin, web_user;
    SQL
    remove_column :balance_transfers, :project_id

  end
end
