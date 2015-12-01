class SpeedupCategoriesEndpoint < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE OR REPLACE VIEW "1".categories AS
SELECT
    c.id,
    c.name_pt AS name,
    count(distinct p.id) filter (where public.is_current_and_online(p.expires_at, coalesce(fp.state, p.state))) as online_projects,
    (
        SELECT count(DISTINCT cf.user_id) AS count
        FROM category_followers cf
        WHERE cf.category_id = c.id
    ) AS followers
FROM
    categories c
    LEFT JOIN projects p ON p.category_id = c.id 
    LEFT JOIN flexible_projects fp ON fp.project_id = p.id    
GROUP BY c.id;
    SQL
  end

  def down
    execute <<-SQL
CREATE OR REPLACE VIEW "1".categories AS
 SELECT c.id,
    c.name_pt AS name,
    ( SELECT count(*) AS count
           FROM public.projects p
          WHERE (public.open_for_contributions(p.*) AND (p.category_id = c.id))) AS online_projects,
    ( SELECT count(DISTINCT cf.user_id) AS count
           FROM public.category_followers cf
          WHERE (cf.category_id = c.id)) AS followers
   FROM public.categories c
  WHERE (EXISTS ( SELECT true AS bool
           FROM public.projects p
          WHERE (p.category_id = c.id)));
    SQL
  end
end
