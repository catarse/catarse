class AddTotalPaymentsServiceFeeIntoProjectTotals < ActiveRecord::Migration
  def up
    execute <<-SQL
      DROP VIEW project_totals;
      CREATE OR REPLACE VIEW project_totals AS
        SELECT
          backers.project_id,
          sum(backers.value) AS pledged,
          sum(backers.payment_service_fee) AS total_payment_service_fee,
          count(*) AS total_backers
        FROM backers
        WHERE (backers.state in ('confirmed', 'refunded', 'requested_refund'))
        GROUP BY backers.project_id;
    SQL
  end

  def down
    execute <<-SQL
      DROP VIEW project_totals;
      CREATE OR REPLACE VIEW project_totals AS
        SELECT backers.project_id, sum(backers.value) AS pledged, count(*) AS total_backers
        FROM backers
        WHERE (backers.state ~* '(confirmed|refunded|requested_refund)$')
        GROUP BY backers.project_id;
    SQL
  end
end
