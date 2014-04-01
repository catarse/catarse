class RecreateProjectsInAnalysisByPeriods < ActiveRecord::Migration
  def change
    execute "
    DROP VIEW projects_in_analysis_by_periods;
    CREATE VIEW projects_in_analysis_by_periods AS
      WITH weeks AS (
        SELECT 
          to_char(current_year.current_year, 'yyyy-mm W'::text) AS current_year,
          to_char(last_year.last_year, 'yyyy-mm W'::text) AS last_year,
          current_year.current_year AS label   
        FROM 
          generate_series(now() - '49 days'::interval, now(), '7 days'::interval) current_year
          JOIN generate_series(now() - '1 year 49 days'::interval, now() - '1 year'::interval, '7 days'::interval) last_year(last_year) ON to_char(last_year.last_year, 'mm W'::text) = to_char(current_year.current_year, 'mm W'::text)
      ),
      current_year AS (
        SELECT w.label, count(*) AS current_year
        FROM 
          projects p
          JOIN weeks w ON w.current_year = to_char(p.sent_to_analysis_at, 'yyyy-mm W'::text)
        GROUP BY w.label
      ),
      last_year AS (
        SELECT w.label, count(*) AS last_year
        FROM 
          projects p
          JOIN weeks w ON w.last_year = to_char(p.sent_to_analysis_at, 'yyyy-mm W'::text)
        GROUP BY w.label
      )
      SELECT * FROM current_year JOIN last_year USING(label);
    "
  end
end
