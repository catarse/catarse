class FixesPaidCountFunction < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE OR REPLACE FUNCTION paid_count(rewards) RETURNS bigint AS $$
      SELECT count(*)
      FROM payments p
      JOIN contributions c ON c.id = p.contribution_id
      JOIN projects prj ON c.project_id = prj.id
      WHERE (CASE WHEN prj.state = 'failed' THEN p.state IN ('refunded', 'pending_refund', 'paid') ELSE p.state = 'paid' END)
        AND c.reward_id = $1.id
    $$ LANGUAGE SQL STABLE SECURITY DEFINER;
    SQL
  end
  def down
    execute <<-SQL
    CREATE OR REPLACE FUNCTION paid_count(rewards) RETURNS bigint AS $$
      SELECT count(*)
      FROM payments p join contributions c on c.id = p.contribution_id
      WHERE p.state = 'paid' AND c.reward_id = $1.id
    $$ LANGUAGE SQL STABLE SECURITY DEFINER;
    SQL
  end
end
