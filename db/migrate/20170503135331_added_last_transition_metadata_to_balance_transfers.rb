class AddedLastTransitionMetadataToBalanceTransfers < ActiveRecord::Migration
  def change
    execute %Q{
CREATE OR REPLACE VIEW "1"."balance_transfers" AS 
  SELECT bt.id,
    bt.user_id,
    bt.project_id,
    bt.amount,
    bt.transfer_id,
    zone_timestamp(bt.created_at) AS created_at,
    zone_timestamp(weekdays_from(10, zone_timestamp(bt.created_at))) AS transfer_limit_date,
    current_state(bt.*) AS state,
    btt.metadata as last_transition_metadata
   FROM balance_transfers bt
    LEFT JOIN balance_transfer_transitions btt on btt.balance_transfer_id = bt.id and btt.most_recent
  WHERE is_owner_or_admin(bt.user_id);
}
  end
end
