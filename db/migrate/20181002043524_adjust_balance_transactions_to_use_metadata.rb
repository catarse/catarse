class AdjustBalanceTransactionsToUseMetadata < ActiveRecord::Migration
  def up
    execute <<-SQL
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
    json_agg(bt.metadata ORDER BY bt.id DESC) AS source
   FROM balance_transactions bt
  WHERE is_owner_or_admin(bt.user_id)
  GROUP BY (zone_timestamp(bt.created_at))::date, bt.user_id
  ORDER BY (zone_timestamp(bt.created_at))::date DESC;
    SQL
  end

  def down
    execute <<-SQL
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
    json_agg(json_build_object('amount', bt.amount, 'event_name', bt.event_name, 'origin_objects', json_build_object('from_user_name', COALESCE(fromuser.public_name, fromuser.name), 'to_user_name', COALESCE(touser.public_name, touser.name), 'service_fee', p.service_fee, 'contributor_name', COALESCE(fu.public_name, fu.name), 'subscriber_name', COALESCE(su.public_name, su.name), 'subscription_reward_label', ((r.minimum_value || ' - '::text) || r.title), 'id', COALESCE(bt.project_id, bt.contribution_id), 'project_name', p.name)) ORDER BY bt.id DESC) AS source
   FROM ((((((((balance_transactions bt
     LEFT JOIN projects p ON ((p.id = bt.project_id)))
     LEFT JOIN contributions c ON ((c.id = bt.contribution_id)))
     LEFT JOIN users fu ON ((fu.id = c.user_id)))
     LEFT JOIN common_schema.catalog_payments sp ON ((sp.id = bt.subscription_payment_uuid)))
     LEFT JOIN users su ON ((su.common_id = sp.user_id)))
     LEFT JOIN rewards r ON ((r.common_id = sp.reward_id)))
     LEFT JOIN users fromuser ON (((fromuser.id = bt.from_user_id) AND (bt.from_user_id IS NOT NULL))))
     LEFT JOIN users touser ON (((touser.id = bt.to_user_id) AND (bt.to_user_id IS NOT NULL))))
  WHERE is_owner_or_admin(bt.user_id)
  GROUP BY (zone_timestamp(bt.created_at))::date, bt.user_id
  ORDER BY (zone_timestamp(bt.created_at))::date DESC;
    SQL
  end
end
