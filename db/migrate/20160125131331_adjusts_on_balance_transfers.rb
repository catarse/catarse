class AdjustsOnBalanceTransfers < ActiveRecord::Migration
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
    'pending'::text AS state
   FROM public.balance_transfers bt
  WHERE public.is_owner_or_admin(bt.user_id);
GRANT SELECT ON "1".balance_transfers TO admin, web_user;
    SQL
  end

  def down
    remove_column :balance_transfers, :project_id

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
  end
end
