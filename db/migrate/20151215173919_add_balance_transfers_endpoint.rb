class AddBalanceTransfersEndpoint < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE OR REPLACE VIEW "1".balance_transfers AS
    SELECT
        bt.id,
        bt.user_id,
        bt.amount,
        bt.transfer_id,
        public.zone_timestamp(bt.created_at) as created_at,
        'pending'::text as state
    FROM public.balance_transfers bt
    WHERE public.is_owner_or_admin(bt.user_id);

GRANT SELECT ON "1".balance_transfers TO admin, web_user;
    SQL
  end

  def down
    execute <<-SQL
DROP VIEW "1".balance_transfers;
    SQL
  end
end
