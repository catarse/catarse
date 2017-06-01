class AddMoreFieldsToOriginObjectsBalanceTransactions < ActiveRecord::Migration
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
    json_agg(
        json_build_object(
            'amount', bt.amount, 
            'event_name', bt.event_name, 
            'origin_objects', json_build_object(
                'service_fee', (select p1.service_fee from projects p1 where p1.id = bt.project_id limit 1),
                'contributor_name', (select u1.public_name from users u1 where u1.id = (
                    select user_id from contributions where contributions.id = bt.contribution_id limit 1
                ) limit 1),
                'id', COALESCE(bt.project_id, bt.contribution_id), 
                'project_name', ( SELECT projects.name
                       FROM projects
                      WHERE (projects.id = bt.project_id) limit 1)
        )) ORDER BY bt.id DESC) AS source
   FROM balance_transactions bt
  WHERE is_owner_or_admin(bt.user_id)
  GROUP BY ((zone_timestamp(bt.created_at))::date), bt.user_id
  ORDER BY ((zone_timestamp(bt.created_at))::date) DESC;
}
  end
end
