class FixesCategoryTotals < ActiveRecord::Migration
  def up
    execute <<-SQL
drop materialized view "1".category_totals;
CREATE MATERIALIZED VIEW "1".category_totals AS
WITH project_stats AS (
     SELECT ca.id AS category_id,
        ca.name_pt AS name,
        count(DISTINCT p_1.id) FILTER (WHERE ((coalesce(fp.state, p_1.state))::text = 'online'::text)) AS online_projects,
        count(DISTINCT p_1.id) FILTER (WHERE ((coalesce(fp.state, p_1.state))::text = 'successful'::text)) AS successful_projects,
        count(DISTINCT p_1.id) FILTER (WHERE ((coalesce(fp.state, p_1.state))::text = 'failed'::text)) AS failed_projects,
        avg(p_1.goal) AS avg_goal,
        avg(pt.pledged) AS avg_pledged,
        sum(pt.pledged) FILTER (WHERE ((coalesce(fp.state, p_1.state))::text = 'successful'::text)) AS total_successful_value,
        sum(pt.pledged) AS total_value
       FROM public.projects p_1
         LEFT JOIN public.flexible_projects fp ON fp.project_id = p_1.id
         JOIN public.categories ca ON ca.id = p_1.category_id
         LEFT JOIN "1".project_totals pt ON pt.project_id = p_1.id
      WHERE coalesce(fp.state,p_1.state) <> ALL (ARRAY[('draft'::character varying)::text, ('in_analysis'::character varying)::text, ('rejected'::character varying)::text])
      GROUP BY ca.id
    ), contribution_stats AS (
     SELECT ca.id AS category_id,
        ca.name_pt,
        avg(pa.value) AS avg_value,
        count(DISTINCT c_1.user_id) AS total_contributors
       FROM (((public.projects p_1
         LEFT JOIN public.flexible_projects fp ON fp.project_id = p_1.id       
         JOIN public.categories ca ON ((ca.id = p_1.category_id)))
         JOIN public.contributions c_1 ON ((c_1.project_id = p_1.id)))
         JOIN public.payments pa ON ((pa.contribution_id = c_1.id)))
      WHERE 
        coalesce(fp.state, p_1.state) <> ALL(ARRAY[('draft'::character varying)::text, 
        ('in_analysis'::character varying)::text, ('rejected'::character varying)::text]) AND (pa.state = ANY(public.confirmed_states()))
      GROUP BY ca.id
    ), followers AS (
     SELECT cf_1.category_id,
        count(DISTINCT cf_1.user_id) AS followers
       FROM public.category_followers cf_1
      GROUP BY cf_1.category_id
    )
SELECT p.category_id,
p.name,
p.online_projects,
p.successful_projects,
p.failed_projects,
p.avg_goal,
p.avg_pledged,
p.total_successful_value,
p.total_value,
c.name_pt,
c.avg_value,
c.total_contributors,
cf.followers
FROM ((project_stats p
 JOIN contribution_stats c USING (category_id))
 LEFT JOIN followers cf USING (category_id));

create unique index on "1".category_totals (category_id);

GRANT SELECT ON "1".category_totals TO admin, anonymous, web_user;
    SQL
  end
end
