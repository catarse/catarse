class AddFullTextIndexToBalanceTranfersView < ActiveRecord::Migration
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
    btt.metadata AS last_transition_metadata,
    zone_timestamp(transferred_transition.created_at) AS transferred_at,
    zone_timestamp(transferred_transition.created_at)::date AS transferred_date,
    zone_timestamp(bt.created_at)::date AS created_date,
    bt.full_text_index as full_text_index,
    u.name as user_name,
    u.public_name as user_public_name,
    u.email as user_email
   FROM (balance_transfers bt
     JOIN users u on u.id = bt.user_id
     LEFT JOIN balance_transfer_transitions btt ON (((btt.balance_transfer_id = bt.id) AND btt.most_recent))
     LEFT JOIN LATERAL (
        select
            *
        from balance_transfer_transitions btt1 
        where btt1.balance_transfer_id = bt.id
            and btt1.to_state = 'transferred'
        order by btt1.id desc limit 1
     ) transferred_transition ON true
    )
  WHERE is_owner_or_admin(bt.user_id);
}
  end
end
