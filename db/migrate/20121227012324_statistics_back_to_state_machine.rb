class StatisticsBackToStateMachine < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE VIEW statistics AS
      SELECT
        (SELECT count(*) FROM users WHERE primary_user_id IS NULL) AS total_users,
        total_backs,
        total_backers,
        total_backed,
        total_projects,
        total_projects_success,
        total_projects_online
      FROM
        (
          SELECT count(*) AS total_backs, 
            count(DISTINCT user_id) AS total_backers, 
            sum(value) AS total_backed 
          FROM backers WHERE confirmed
        ) AS backers_totals,

        (
          SELECT 
            count(*) AS total_projects, 
            count(CASE WHEN state = 'successful' THEN 1 ELSE NULL END) AS total_projects_success, 
            count(CASE WHEN state = 'online' THEN 1 ELSE NULL END) AS total_projects_online 
          FROM projects WHERE state NOT IN ('draft', 'rejected')
        ) AS projects_totals
    SQL
  end

  def down
    execute <<SQL
    CREATE OR REPLACE VIEW statistics AS
    SELECT
      (SELECT count(*) FROM users WHERE primary_user_id IS NULL) AS total_users,
      total_backs,
      total_backers,
      total_backed,
      total_projects,
      total_projects_success,
      total_projects_online
    FROM
      (SELECT count(*) AS total_backs, count(DISTINCT user_id) AS total_backers, sum(value) AS total_backed FROM backers WHERE confirmed) AS backers_totals,
      (SELECT count(*) AS total_projects, count(CASE WHEN successful THEN 1 ELSE NULL END) AS total_projects_success, count(CASE WHEN finished = false AND expires_at >= current_timestamp THEN 1 ELSE NULL END) AS total_projects_online FROM projects WHERE visible) AS projects_totals
SQL
  end
end
