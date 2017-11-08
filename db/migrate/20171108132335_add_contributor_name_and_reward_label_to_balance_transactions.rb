class AddContributorNameAndRewardLabelToBalanceTransactions < ActiveRecord::Migration
  def up
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
            'origin_objects', 
            json_build_object(
            'service_fee', ( SELECT p1.service_fee
                FROM projects p1
                WHERE (p1.id = bt.project_id)
                LIMIT 1), 
            'contributor_name', ( SELECT u1.public_name
                FROM users u1
                WHERE (u1.id = ( SELECT contributions.user_id
                   FROM contributions
                    WHERE (contributions.id = bt.contribution_id)
                    LIMIT 1))
                LIMIT 1),
            'subscriber_name', ( SELECT u1.public_name
                FROM users u1
                WHERE (u1.id = ( SELECT subscriptions.user_id
                   FROM subscriptions
                    join subscription_payments on subscription_payments.subscription_id = subscriptions.id
                    WHERE (subscriptions.id = subscription_payments.subscription_id)
                        AND (subscription_payments.id = bt.subscription_payment_id)
                    LIMIT 1))
                LIMIT 1),
            'subscription_reward_label', ( SELECT r1.minimum_value|| ' - '||r1.title
                FROM rewards r1
                WHERE (r1.id = ( SELECT subscriptions.reward_id
                   FROM subscriptions
                    join subscription_payments on subscription_payments.subscription_id = subscriptions.id
                    WHERE (subscriptions.id = subscription_payments.subscription_id)
                        AND (subscription_payments.id = bt.subscription_payment_id)
                        AND subscriptions.reward_id is not null
                    LIMIT 1))
                LIMIT 1),            
            'id', COALESCE(bt.project_id, bt.contribution_id), 
            'project_name', ( SELECT projects.name
                FROM projects
                WHERE (projects.id = bt.project_id)
                LIMIT 1))
            ) ORDER BY bt.id DESC) AS source
    FROM balance_transactions bt
    WHERE is_owner_or_admin(bt.user_id) 
    GROUP BY (zone_timestamp(bt.created_at))::date, bt.user_id
    ORDER BY (zone_timestamp(bt.created_at))::date DESC;
}
  end

  def down
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
    json_agg(json_build_object('amount', bt.amount, 'event_name', bt.event_name, 'origin_objects', json_build_object('service_fee', ( SELECT p1.service_fee
           FROM projects p1
          WHERE (p1.id = bt.project_id)
         LIMIT 1), 'contributor_name', ( SELECT u1.public_name
           FROM users u1
          WHERE (u1.id = ( SELECT contributions.user_id
                   FROM contributions
                  WHERE (contributions.id = bt.contribution_id)
                 LIMIT 1))
         LIMIT 1), 'id', COALESCE(bt.project_id, bt.contribution_id), 'project_name', ( SELECT projects.name
           FROM projects
          WHERE (projects.id = bt.project_id)
         LIMIT 1))) ORDER BY bt.id DESC) AS source
   FROM balance_transactions bt
  WHERE is_owner_or_admin(bt.user_id)
  GROUP BY (zone_timestamp(bt.created_at))::date, bt.user_id
  ORDER BY (zone_timestamp(bt.created_at))::date DESC;
}
  end
end
