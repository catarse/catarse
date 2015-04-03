class RefactorCanRefundFunction < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE OR REPLACE FUNCTION can_refund(contributions) RETURNS boolean AS $$
      SELECT
        $1.was_confirmed AND
        EXISTS(
          SELECT true
          FROM projects p
          WHERE p.id = $1.project_id and p.state = 'failed'
        )
    $$ LANGUAGE sql;
    SQL
  end

  def down
    execute <<-SQL
    CREATE OR REPLACE FUNCTION can_refund(contributions) RETURNS boolean AS $$
      SELECT
        $1.state IN('confirmed', 'requested_refund', 'refunded') AND
        NOT $1.credits AND
        EXISTS(
          SELECT true
          FROM projects p
          WHERE p.id = $1.project_id and p.state = 'failed'
        )
    $$ LANGUAGE sql;
    SQL
  end
end
