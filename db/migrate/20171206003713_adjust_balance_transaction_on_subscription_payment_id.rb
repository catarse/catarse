class AdjustBalanceTransactionOnSubscriptionPaymentId < ActiveRecord::Migration[4.2]
  def change
    execute %Q{
alter table balance_transactions
    add column subscription_payment_uuid uuid;

update balance_transactions
    set subscription_payment_uuid = sp.common_id
    from public.subscription_payments sp
    where balance_transactions.subscription_payment_id is not null
        and sp.id = balance_transactions.subscription_payment_id;

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
    json_agg(json_build_object('amount', bt.amount, 'event_name', bt.event_name, 'origin_objects', json_build_object('service_fee', ( SELECT p1.service_fee
           FROM projects p1
          WHERE (p1.id = bt.project_id)
         LIMIT 1), 'contributor_name', ( SELECT u1.public_name
           FROM users u1
          WHERE (u1.id = ( SELECT contributions.user_id
                   FROM contributions
                  WHERE (contributions.id = bt.contribution_id)
                 LIMIT 1))
         LIMIT 1), 'subscriber_name', ( SELECT u1.public_name
           FROM users u1
          WHERE (u1.common_id = ( SELECT s1.user_id
                   FROM (common_schema.subscriptions s1
                     JOIN common_schema.catalog_payments cp1 ON ((cp1.subscription_id = s1.id)))
                  WHERE ((s1.id = cp1.subscription_id) AND (cp1.id = bt.subscription_payment_uuid))
                 LIMIT 1))
         LIMIT 1), 'subscription_reward_label', ( SELECT ((r1.minimum_value || ' - '::text) || r1.title)
           FROM rewards r1
          WHERE (r1.common_id = ( SELECT s1.reward_id
                   FROM (common_schema.subscriptions s1
                     JOIN common_schema.catalog_payments cp1 ON ((cp1.subscription_id = s1.id)))
                  WHERE (((s1.id = cp1.subscription_id) AND (cp1.id = bt.subscription_payment_uuid)) AND (s1.reward_id IS NOT NULL))
                 LIMIT 1))
         LIMIT 1), 'id', COALESCE(bt.project_id, bt.contribution_id), 'project_name', ( SELECT projects.name
           FROM projects
          WHERE (projects.id = bt.project_id)
         LIMIT 1))) ORDER BY bt.id DESC) AS source
   FROM balance_transactions bt
  WHERE is_owner_or_admin(bt.user_id)
  GROUP BY (zone_timestamp(bt.created_at))::date, bt.user_id
  ORDER BY (zone_timestamp(bt.created_at))::date DESC;

alter table balance_transactions
    drop column subscription_payment_id;
}
  end
end
