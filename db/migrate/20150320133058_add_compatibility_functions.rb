class AddCompatibilityFunctions < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE OR REPLACE FUNCTION confirmed_states() RETURNS text[] AS $$
      SELECT '{"paid", "pending_refund", "refunded"}'::text[];
    $$ LANGUAGE SQL;

    CREATE OR REPLACE FUNCTION confirmed(contributions) RETURNS boolean AS $$
      SELECT EXISTS (
        SELECT true
        FROM 
          payments p 
          JOIN contributions_payments cp ON cp.payment_id = p.id
        WHERE cp.contribution_id = $1.id AND p.state = ANY(confirmed_states())
      );
    $$ LANGUAGE SQL;
    SQL
  end

  def down
    execute <<-SQL
    DROP FUNCTION confirmed_states();
    SQL
  end
end
