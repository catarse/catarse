class InsertProjectTransitions < ActiveRecord::Migration
  def change
    execute <<-SQL
SET statement_timeout TO 0;
    SQL

    execute <<-SQL
-- in_analysis projects
INSERT INTO project_transitions (to_state, sort_key, project_id, most_recent, created_at, updated_at)
SELECT
    'in_analysis',
    0,
    p.id,
    true,
    coalesce(p.sent_to_analysis_at, p.updated_at),
    coalesce(p.sent_to_analysis_at, p.updated_at)
FROM
    projects p
WHERE
    p.state = 'in_analysis';

-- approved projects
INSERT INTO project_transitions (to_state, sort_key, project_id, most_recent, created_at, updated_at)
SELECT
    'in_analysis',
    0,
    p.id,
    false,
    coalesce(p.sent_to_analysis_at, p.updated_at),
    coalesce(p.sent_to_analysis_at, p.updated_at)
FROM
    projects p
WHERE
    p.state = 'approved'
UNION
SELECT
    'approved',
    1,
    p.id,
    true,
    -- we do not have the approval date in the database
    coalesce(p.sent_to_analysis_at, p.updated_at),
    coalesce(p.sent_to_analysis_at, p.updated_at)
FROM
    projects p
WHERE
    p.state = 'approved';

-- online projects
INSERT INTO project_transitions (to_state, sort_key, project_id, most_recent, created_at, updated_at)
SELECT
    'in_analysis',
    0,
    p.id,
    false,
    coalesce(p.sent_to_analysis_at, p.updated_at),
    coalesce(p.sent_to_analysis_at, p.updated_at)
FROM
    projects p
WHERE
    p.state = 'online'
UNION
SELECT
    'approved',
    1,
    p.id,
    false,
    -- we do not have the approval date in the database
    coalesce(p.sent_to_analysis_at, p.updated_at),
    coalesce(p.sent_to_analysis_at, p.updated_at)
FROM
    projects p
WHERE
    p.state = 'online'
UNION
SELECT
    'online',
    2,
    p.id,
    true,
    -- we do not have the approval date in the database
    coalesce(p.online_date, p.updated_at),
    coalesce(p.online_date, p.updated_at)
FROM
    projects p
WHERE
    p.state = 'online';

-- waiting_funds projects
INSERT INTO project_transitions (to_state, sort_key, project_id, most_recent, created_at, updated_at)
SELECT
    'in_analysis',
    0,
    p.id,
    false,
    coalesce(p.sent_to_analysis_at, p.updated_at),
    coalesce(p.sent_to_analysis_at, p.updated_at)
FROM
    projects p
WHERE
    p.state = 'waiting_funds'
UNION
SELECT
    'approved',
    1,
    p.id,
    false,
    -- we do not have the approval date in the database
    coalesce(p.sent_to_analysis_at, p.updated_at),
    coalesce(p.sent_to_analysis_at, p.updated_at)
FROM
    projects p
WHERE
    p.state = 'waiting_funds'
UNION
SELECT
    'online',
    2,
    p.id,
    false,
    -- we do not have the approval date in the database
    coalesce(p.online_date, p.updated_at),
    coalesce(p.online_date, p.updated_at)
FROM
    projects p
WHERE
    p.state = 'waiting_funds'
UNION
SELECT
    'waiting_funds',
    3,
    p.id,
    true,
    -- we do not have the approval date in the database
    coalesce(p.expires_at, p.updated_at),
    coalesce(p.expires_at, p.updated_at)
FROM
    projects p
WHERE
    p.state = 'waiting_funds';

-- successful projects
INSERT INTO project_transitions (to_state, sort_key, project_id, most_recent, created_at, updated_at)
SELECT
    'in_analysis',
    0,
    p.id,
    false,
    coalesce(p.sent_to_analysis_at, p.updated_at),
    coalesce(p.sent_to_analysis_at, p.updated_at)
FROM
    projects p
WHERE
    p.state = 'successful'
UNION
SELECT
    'approved',
    1,
    p.id,
    false,
    -- we do not have the approval date in the database
    coalesce(p.sent_to_analysis_at, p.updated_at),
    coalesce(p.sent_to_analysis_at, p.updated_at)
FROM
    projects p
WHERE
    p.state = 'successful'
UNION
SELECT
    'online',
    2,
    p.id,
    false,
    -- we do not have the approval date in the database
    coalesce(p.online_date, p.updated_at),
    coalesce(p.online_date, p.updated_at)
FROM
    projects p
WHERE
    p.state = 'successful'
UNION
SELECT
    'waiting_funds',
    3,
    p.id,
    false,
    -- we do not have the approval date in the database
    coalesce(p.expires_at, p.updated_at),
    coalesce(p.expires_at, p.updated_at)
FROM
    projects p
WHERE
    p.state = 'successful'
UNION
SELECT
    'successful',
    4,
    p.id,
    true,
    -- we do not have the successful date in the database
    coalesce(p.expires_at, p.updated_at),
    coalesce(p.expires_at, p.updated_at)
FROM
    projects p
WHERE
    p.state = 'successful';

-- failed projects
INSERT INTO project_transitions (to_state, sort_key, project_id, most_recent, created_at, updated_at)
SELECT
    'in_analysis',
    0,
    p.id,
    false,
    coalesce(p.sent_to_analysis_at, p.updated_at),
    coalesce(p.sent_to_analysis_at, p.updated_at)
FROM
    projects p
WHERE
    p.state = 'failed'
UNION
SELECT
    'approved',
    1,
    p.id,
    false,
    -- we do not have the approval date in the database
    coalesce(p.sent_to_analysis_at, p.updated_at),
    coalesce(p.sent_to_analysis_at, p.updated_at)
FROM
    projects p
WHERE
    p.state = 'failed'
UNION
SELECT
    'online',
    2,
    p.id,
    false,
    -- we do not have the approval date in the database
    coalesce(p.online_date, p.updated_at),
    coalesce(p.online_date, p.updated_at)
FROM
    projects p
WHERE
    p.state = 'failed'
UNION
SELECT
    'waiting_funds',
    3,
    p.id,
    false,
    -- we do not have the approval date in the database
    coalesce(p.expires_at, p.updated_at),
    coalesce(p.expires_at, p.updated_at)
FROM
    projects p
WHERE
    p.state = 'failed'
UNION
SELECT
    'failed',
    4,
    p.id,
    true,
    -- we do not have the failed date in the database
    coalesce(p.expires_at, p.updated_at),
    coalesce(p.expires_at, p.updated_at)
FROM
    projects p
WHERE
    p.state = 'failed';

-- deleted projects
INSERT INTO project_transitions (to_state, sort_key, project_id, most_recent, created_at, updated_at)
SELECT
    'deleted',
    0,
    p.id,
    true,
    coalesce(p.sent_to_analysis_at, p.updated_at),
    coalesce(p.sent_to_analysis_at, p.updated_at)
FROM
    projects p
WHERE
    p.state = 'deleted';

-- rejected projects
INSERT INTO project_transitions (to_state, sort_key, project_id, most_recent, created_at, updated_at)
SELECT
    'in_analysis',
    0,
    p.id,
    false,
    coalesce(p.sent_to_analysis_at, p.updated_at),
    coalesce(p.sent_to_analysis_at, p.updated_at)
FROM
    projects p
WHERE
    p.state = 'rejected'
UNION
SELECT
    'rejected',
    1,
    p.id,
    true,
    -- we do not have the approval date in the database
    coalesce(p.rejected_at, p.updated_at),
    coalesce(p.rejected_at, p.updated_at)
FROM
    projects p
WHERE
    p.state = 'rejected';

    SQL
  end
end
