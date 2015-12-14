class UpdateStatisticsToUseFlex < ActiveRecord::Migration
  def up
    execute <<-SQL
set statement_timeout to 0;
DROP MATERIALIZED VIEW "1".statistics;
CREATE MATERIALIZED VIEW "1".statistics AS
    SELECT 
        ( SELECT count(*) AS count
            FROM users) AS total_users,
        contributions_totals.total_contributions,
        contributions_totals.total_contributors,
        contributions_totals.total_contributed,
        projects_totals.total_projects,
        projects_totals.total_projects_success,
        projects_totals.total_projects_online
    FROM ( 
        SELECT 
            count(DISTINCT c.id) AS total_contributions,
            count(DISTINCT c.user_id) AS total_contributors,
            sum(p.value) AS total_contributed
        FROM contributions c
        JOIN payments p ON p.contribution_id = c.id
        WHERE 
            p.state = ANY (confirmed_states())
    ) contributions_totals,
    ( 
        SELECT 
            count(*) AS total_projects,
            count(
                CASE
                WHEN coalesce(fp.state, p.state)::text = 'successful'::text THEN 1
                ELSE NULL::integer
                END) AS total_projects_success,
            count(
                CASE
                WHEN coalesce(fp.state, p.state)::text = 'online'::text THEN 1
                ELSE NULL::integer
                END) AS total_projects_online
        FROM public.projects p
        LEFT JOIN public.flexible_projects fp on fp.project_id = p.id
        WHERE coalesce(fp.state, p.state)::text <> ALL (ARRAY['draft', 'rejected'])
    ) projects_totals;
    SQL
  end

  def down
    execute <<-SQL
set statement_timeout to 0;
DROP MATERIALIZED VIEW "1".statistics;
CREATE OR REPLACE MATERIALIZED VIEW "1".statistics AS
 SELECT ( SELECT count(*) AS count
           FROM users) AS total_users,
    contributions_totals.total_contributions,
    contributions_totals.total_contributors,
    contributions_totals.total_contributed,
    projects_totals.total_projects,
    projects_totals.total_projects_success,
    projects_totals.total_projects_online
   FROM ( SELECT count(DISTINCT c.id) AS total_contributions,
            count(DISTINCT c.user_id) AS total_contributors,
            sum(p.value) AS total_contributed
           FROM contributions c
             JOIN payments p ON p.contribution_id = c.id
          WHERE p.state = ANY (confirmed_states())) contributions_totals,
    ( SELECT count(*) AS total_projects,
            count(
                CASE
                    WHEN projects.state::text = 'successful'::text THEN 1
                    ELSE NULL::integer
                END) AS total_projects_success,
            count(
                CASE
                    WHEN projects.state::text = 'online'::text THEN 1
                    ELSE NULL::integer
                END) AS total_projects_online
           FROM projects
          WHERE projects.state::text <> ALL (ARRAY['draft'::character varying::text, 'rejected'::character varying::text])) projects_totals;
    SQL
  end
end
