class CreateNewBackerTotals < ActiveRecord::Migration
  def up
    execute <<SQL
    CREATE OR REPLACE VIEW backer_totals AS 
    SELECT 
      b.user_id, 
      sum(b.value) AS sum, 
      count(*) AS count,
      sum(CASE 
        WHEN p.finished AND NOT p.successful AND NOT b.credits AND NOT b.requested_refund THEN b.value 
        WHEN (NOT p.finished OR p.successful) AND b.credits THEN b.value * -1
        ELSE 0
      END) AS credits
    FROM 
      backers b
      JOIN projects p ON (b.project_id = p.id)
    WHERE b.confirmed = true
    GROUP BY b.user_id;
SQL
  end

  def down
    execute "DROP VIEW backer_totals"
  end
end
