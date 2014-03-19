class CreateProjectsInAnalysisByPeriods < ActiveRecord::Migration
  def up
    create_view :projects_in_analysis_by_periods, <<-SQL
WITH weeks AS (
  SELECT
    generate_series * 7 AS days
  FROM generate_series(0, 7)
),
current_period AS (
SELECT
  'current_period'::text as series,
  count(*),
  w.days / 7 as week
FROM
  projects p
  RIGHT JOIN weeks w ON p.sent_to_analysis_at::date >= (current_date - w.days - 7) AND p.sent_to_analysis_at < (current_date - w.days)
GROUP BY week
),
previous_period AS (
SELECT
  'previous_period'::text as series,
  count(*),
  w.days / 7 as week
FROM
  projects p
  RIGHT JOIN weeks w ON p.sent_to_analysis_at::date >= (current_date - w.days - 7 - 56) AND p.sent_to_analysis_at < (current_date - w.days - 56)
GROUP BY week
),
last_year AS (
SELECT
  'last_year'::text as series,
  count(*),
  w.days / 7 as week
FROM
  projects p
  RIGHT JOIN weeks w ON p.sent_to_analysis_at::date >= (current_date - w.days - 7 - 365) AND p.sent_to_analysis_at < (current_date - w.days - 365)
GROUP BY week
)
(SELECT * FROM current_period)
UNION ALL
(SELECT * FROM previous_period)
UNION ALL
(SELECT * FROM last_year)
ORDER BY series, week;
    SQL
  end

  def down
    drop_view :projects_in_analysis_by_periods
  end
end
