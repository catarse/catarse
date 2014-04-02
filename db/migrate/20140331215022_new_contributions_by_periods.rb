class NewContributionsByPeriods < ActiveRecord::Migration
  def change
    execute "
    DROP VIEW contributions_by_periods;
    CREATE VIEW contributions_by_periods AS
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
        SELECT w.label, sum(cc.value) AS current_year
        FROM 
          contributions cc
          JOIN weeks w ON w.current_year = to_char(cc.confirmed_at, 'yyyy-mm W'::text)
        WHERE cc.state::text = 'confirmed'::text 
        GROUP BY w.label
      ),
      last_year AS (
        SELECT w.label, sum(cc.value) AS last_year
        FROM 
          contributions cc
          JOIN weeks w ON w.last_year = to_char(cc.confirmed_at, 'yyyy-mm W'::text)
        WHERE cc.state::text = 'confirmed'::text 
        GROUP BY w.label
      )
      SELECT * FROM current_year JOIN last_year USING(label);
    "
  end
end
