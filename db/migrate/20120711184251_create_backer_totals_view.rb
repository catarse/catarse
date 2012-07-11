class CreateBackerTotalsView < ActiveRecord::Migration
  def up
    execute <<SQL
    CREATE OR REPLACE VIEW backer_totals AS 
    SELECT project_id, sum(value) AS pledged, count(*) AS total_backers
    FROM backers
    WHERE confirmed = true
    GROUP BY project_id;
SQL
  end

  def down
    execute "DROP VIEW backer_totals"
  end
end
