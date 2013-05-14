class DropViews < ActiveRecord::Migration
  def up
    execute "
DROP VIEW IF EXISTS backers_by_category;
DROP VIEW IF EXISTS backers_by_payment_choice;
DROP VIEW IF EXISTS backers_by_project CASCADE;
DROP VIEW IF EXISTS projects_by_total_backed_ranges;
DROP VIEW IF EXISTS projects_by_year;
DROP VIEW IF EXISTS projects_by_category;
DROP VIEW IF EXISTS projects_by_state;
DROP VIEW IF EXISTS backers_by_state;
DROP VIEW IF EXISTS backers_by_year CASCADE;
DROP VIEW IF EXISTS paypal_pending;
DROP VIEW IF EXISTS project_totals;
DROP VIEW IF EXISTS recurring_backers_by_year;
DROP VIEW IF EXISTS rewards_by_range;
    "
    create_view :project_totals, "SELECT backers.project_id, sum(backers.value) AS pledged, 
    count(*) AS total_backers
   FROM backers
  WHERE backers.state = 'confirmed'
  GROUP BY backers.project_id;"
  end

  def down
    execute "
DROP VIEW IF EXISTS project_totals;
    "
    create_view :project_totals, "SELECT backers.project_id, sum(backers.value) AS pledged, 
    count(*) AS total_backers
   FROM backers
  WHERE backers.confirmed
  GROUP BY backers.project_id;"
  end
end
