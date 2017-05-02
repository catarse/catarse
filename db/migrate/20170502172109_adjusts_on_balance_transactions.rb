class AdjustsOnBalanceTransactions < ActiveRecord::Migration
  def change
    execute %Q{
CREATE OR REPLACE VIEW "1"."balance_transactions" AS 
 SELECT bt.user_id,
    sum(
        CASE
            WHEN (bt.amount > (0)::numeric) THEN bt.amount
            ELSE (0)::numeric
        END) AS credit,
    sum(
        CASE
            WHEN (bt.amount < (0)::numeric) THEN bt.amount
            ELSE (0)::numeric
        END) AS debit,
    sum(bt.amount) AS total_amount,
    (zone_timestamp(bt.created_at))::date AS created_at,
    json_agg(json_build_object('amount', bt.amount, 'event_name', bt.event_name, 'origin_object', json_build_object('id', COALESCE(bt.project_id, bt.contribution_id), 'references_to',
        CASE
            WHEN (bt.project_id IS NOT NULL) THEN 'project'::text
            WHEN (bt.contribution_id IS NOT NULL) THEN 'contribution'::text
            WHEN (bt.balance_transfer_id IS NOT NULL) THEN 'balance_transfer'::text
            ELSE NULL::text
        END, 'name',
        CASE
            WHEN (bt.project_id IS NOT NULL) THEN ( SELECT projects.name
               FROM projects
              WHERE (projects.id = bt.project_id))
            ELSE NULL::text
        END)) order by bt.id desc) AS source
   FROM balance_transactions bt
  WHERE is_owner_or_admin(bt.user_id)
  GROUP BY zone_timestamp(bt.created_at)::date, bt.user_id
  ORDER BY ((zone_timestamp(bt.created_at))::date) DESC;
}
  end
end
