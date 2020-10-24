class AddSubsToRewardDetails < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL
    CREATE OR REPLACE FUNCTION paid_count(rewards) RETURNS bigint AS $$
    SELECT case when (SELECT p.mode from projects p join rewards r on r.project_id = p.id where r.id = $1.id) = 'sub' THEN
 (SELECT count(*)
                           FROM subscriptions s
                           where s.status = 'active'
                             AND s.reward_id = $1.id)
    else
 (SELECT count(*)
                           FROM payments p
                           JOIN contributions c ON c.id = p.contribution_id
                           JOIN projects prj ON c.project_id = prj.id
                           WHERE (CASE WHEN prj.state = 'failed' THEN p.state IN ('refunded', 'pending_refund', 'paid') ELSE p.state = 'paid' END)
                             AND c.reward_id = $1.id)
                             END
    $$ LANGUAGE SQL STABLE SECURITY DEFINER;


    CREATE OR REPLACE FUNCTION waiting_payment_count(rewards) RETURNS bigint AS $$
    SELECT case when (SELECT p.mode from projects p join rewards r on r.project_id = p.id where r.id = $1.id) = 'sub' THEN
    (
      SELECT count(*)
      FROM subscriptions s
      WHERE s.status = 'started' and s.reward_id = $1.id
      )
    ELSE
    (
      SELECT count(*)
      FROM payments p join contributions c on c.id = p.contribution_id
      WHERE p.waiting_payment AND c.reward_id = $1.id
      )
      END
    $$ LANGUAGE SQL STABLE SECURITY DEFINER;
    SQL
  end
end
