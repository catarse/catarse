class AddProgressToProjectTotals < ActiveRecord::Migration
  def up
    execute <<-SQL
     DROP VIEW project_totals;
     CREATE OR REPLACE VIEW project_totals AS
       SELECT
         backers.project_id,
         sum(backers.value) AS pledged,
         (sum(backers.value)/projects.goal)*100 as progress,
         sum(backers.payment_service_fee) AS total_payment_service_fee,
        count(*) AS total_backers
      FROM backers
      JOIN projects ON backers.project_id = projects.id
      WHERE (backers.state in ('confirmed', 'refunded', 'requested_refund'))
      GROUP BY backers.project_id, projects.goal;
      SQL
    end
end
