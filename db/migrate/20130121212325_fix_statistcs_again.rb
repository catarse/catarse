class FixStatistcsAgain < ActiveRecord::Migration
  def up
    execute <<-SQL
 CREATE OR REPLACE VIEW statistics AS
   SELECT ( SELECT count(*) AS count
           FROM users
          WHERE users.primary_user_id IS NULL) AS total_users, backers_totals.total_backs, backers_totals.total_backers, backers_totals.total_backed, projects_totals.total_projects, projects_totals.total_projects_success, projects_totals.total_projects_online
   FROM ( SELECT count(*) AS total_backs, count(DISTINCT backers.user_id) AS total_backers, sum(backers.value) AS total_backed
           FROM backers
          WHERE backers.confirmed) backers_totals, ( SELECT count(*) AS total_projects, count(
                CASE
                    WHEN projects.state::text = 'successful'::text THEN 1
                    ELSE NULL::integer
                END) AS total_projects_success, count(
                CASE
                    WHEN projects.state = 'online' THEN 1
                    ELSE NULL::integer
                END) AS total_projects_online
           FROM projects
          WHERE projects.state::text <> ALL (ARRAY['draft'::character varying, 'rejected'::character varying]::text[])) projects_totals;
SQL
  end

  def down
    execute <<-SQL
 CREATE OR REPLACE VIEW statistics AS
   SELECT ( SELECT count(*) AS count
           FROM users
          WHERE users.primary_user_id IS NULL) AS total_users, backers_totals.total_backs, backers_totals.total_backers, backers_totals.total_backed, projects_totals.total_projects, projects_totals.total_projects_success, projects_totals.total_projects_online
   FROM ( SELECT count(*) AS total_backs, count(DISTINCT backers.user_id) AS total_backers, sum(backers.value) AS total_backed
           FROM backers
          WHERE backers.confirmed) backers_totals, ( SELECT count(*) AS total_projects, count(
                CASE
                    WHEN projects.state::text = 'successful'::text THEN 1
                    ELSE NULL::integer
                END) AS total_projects_success, count(
                CASE
                    WHEN projects.state IN ('online', 'successful') AND projects.expires_at >= current_timestamp THEN 1
                    ELSE NULL::integer
                END) AS total_projects_online
           FROM projects
          WHERE projects.state::text <> ALL (ARRAY['draft'::character varying, 'rejected'::character varying]::text[])) projects_totals;
SQL
  end
end
