class FixProjectTotalToUseRefundedAndRequestedRefundToo < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE VIEW project_totals AS
        SELECT backers.project_id, sum(backers.value) AS pledged, count(*) AS total_backers
        FROM backers
        WHERE (backers.state ~* '(confirmed|refunded|requested_refund)')
        GROUP BY backers.project_id;
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
