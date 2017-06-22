class AddAdminNotesToBalanceTransfersEndpoint < ActiveRecord::Migration
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
    (zone_timestamp(transferred_transition.created_at))::date AS transferred_date,
    (zone_timestamp(bt.created_at))::date AS created_date,
    bt.full_text_index,
    u.name AS user_name,
    u.public_name AS user_public_name,
    u.email AS user_email,
    (case when current_user = 'admin' then admin_notes else null::text end) AS admin_notes
   FROM (((balance_transfers bt
     JOIN users u ON ((u.id = bt.user_id)))
     LEFT JOIN balance_transfer_transitions btt ON (((btt.balance_transfer_id = bt.id) AND btt.most_recent)))
     LEFT JOIN LATERAL ( SELECT btt1.id,
            btt1.to_state,
            btt1.metadata,
            btt1.sort_key,
            btt1.balance_transfer_id,
            btt1.most_recent,
            btt1.created_at,
            btt1.updated_at
           FROM balance_transfer_transitions btt1
          WHERE ((btt1.balance_transfer_id = bt.id) AND ((btt1.to_state)::text = 'transferred'::text))
          ORDER BY btt1.id DESC
         LIMIT 1) transferred_transition ON (true))
  WHERE is_owner_or_admin(bt.user_id);
}
  end
end
