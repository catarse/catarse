class FixesTransferLimitDate < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE VIEW "1"."balance_transfers" AS
 SELECT bt.id,
    bt.user_id,
    bt.project_id,
    bt.amount,
    bt.transfer_id,
    zone_timestamp(bt.created_at) AS created_at,
    zone_timestamp(weekdays_from(10, zone_timestamp(bt.created_at))) AS transfer_limit_date,
    current_state(bt.*) AS state
   FROM balance_transfers bt
  WHERE is_owner_or_admin(bt.user_id);
}
  end

  def down
    execute %Q{
CREATE OR REPLACE VIEW "1"."balance_transfers" AS
 SELECT bt.id,
    bt.user_id,
    bt.project_id,
    bt.amount,
    bt.transfer_id,
    zone_timestamp(bt.created_at) AS created_at,
    zone_timestamp(weekdays_from(10, bt.created_at)) AS transfer_limit_date,
    current_state(bt.*) AS state
   FROM balance_transfers bt
  WHERE is_owner_or_admin(bt.user_id);
}
  end
end
