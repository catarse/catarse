class UpdateBackersByPeriodViewWithDeletedBackerState < ActiveRecord::Migration
  def up
    drop_view :backers_by_periods
    create_view :backers_by_periods, <<-SQL
WITH weeks AS (
  SELECT 
    generate_series * 7 AS days
  FROM generate_series(0, 7)
), 
current_period AS (
SELECT 
  'current_period'::text as series, 
  sum(b.value),
  w.days / 7 as week
FROM 
  backers b 
  RIGHT JOIN weeks w ON b.confirmed_at::date >= (current_date - w.days - 7) AND b.confirmed_at < (current_date - w.days)
WHERE
  state NOT IN ('pending', 'canceled', 'waiting_confirmation', 'deleted')
GROUP BY week
),
previous_period AS (
SELECT 
  'previous_period'::text as series, 
  sum(b.value),
  w.days / 7 as week
FROM 
  backers b 
  RIGHT JOIN weeks w ON b.confirmed_at::date >= (current_date - w.days - 7 - 56) AND b.confirmed_at < (current_date - w.days - 56)
WHERE
  state NOT IN ('pending', 'canceled', 'waiting_confirmation', 'deleted')
GROUP BY week
),
last_year AS (
SELECT 
  'last_year'::text as series, 
  sum(b.value),
  w.days / 7 as week
FROM 
  backers b 
  RIGHT JOIN weeks w ON b.confirmed_at::date >= (current_date - w.days - 7 - 365) AND b.confirmed_at < (current_date - w.days - 365)
WHERE
  state NOT IN ('pending', 'canceled', 'waiting_confirmation', 'deleted')
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
    drop_view :backers_by_periods
    create_view :backers_by_periods, <<-SQL
WITH weeks AS (
  SELECT 
    generate_series * 7 AS days
  FROM generate_series(0, 7)
), 
current_period AS (
SELECT 
  'current_period'::text as series, 
  sum(b.value),
  w.days / 7 as week
FROM 
  backers b 
  RIGHT JOIN weeks w ON b.confirmed_at::date >= (current_date - w.days - 7) AND b.confirmed_at < (current_date - w.days)
WHERE
  state NOT IN ('pending', 'canceled', 'waiting_confirmation')
GROUP BY week
),
previous_period AS (
SELECT 
  'previous_period'::text as series, 
  sum(b.value),
  w.days / 7 as week
FROM 
  backers b 
  RIGHT JOIN weeks w ON b.confirmed_at::date >= (current_date - w.days - 7 - 56) AND b.confirmed_at < (current_date - w.days - 56)
WHERE
  state NOT IN ('pending', 'canceled', 'waiting_confirmation')
GROUP BY week
),
last_year AS (
SELECT 
  'last_year'::text as series, 
  sum(b.value),
  w.days / 7 as week
FROM 
  backers b 
  RIGHT JOIN weeks w ON b.confirmed_at::date >= (current_date - w.days - 7 - 365) AND b.confirmed_at < (current_date - w.days - 365)
WHERE
  state NOT IN ('pending', 'canceled', 'waiting_confirmation')
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
end
