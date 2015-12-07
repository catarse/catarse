class AddsFollowingToCategories < ActiveRecord::Migration
  def up
    execute <<-SQL
DROP VIEW "1".categories;
CREATE OR REPLACE VIEW "1".categories AS
 SELECT c.id,
    c.name_pt AS name,
    count(DISTINCT p.id) FILTER (WHERE public.is_current_and_online(p.expires_at, COALESCE(fp.state, (p.state)::text))) AS online_projects,
    ( SELECT count(DISTINCT cf.user_id)
           FROM public.category_followers cf
          WHERE cf.category_id = c.id) AS followers,
    EXISTS ( SELECT true
           FROM public.category_followers cf
          WHERE cf.category_id = c.id AND cf.user_id = current_user_id()) AS following
   FROM ((public.categories c
     LEFT JOIN public.projects p ON ((p.category_id = c.id)))
     LEFT JOIN public.flexible_projects fp ON ((fp.project_id = p.id)))
  GROUP BY c.id;

GRANT SELECT on "1".categories TO admin, web_user, anonymous;
    SQL
  end

  def down
    execute <<-SQL
DROP VIEW "1".categories;
CREATE OR REPLACE VIEW "1".categories AS
 SELECT c.id,
    c.name_pt AS name,
    count(DISTINCT p.id) FILTER (WHERE public.is_current_and_online(p.expires_at, COALESCE(fp.state, (p.state)::text))) AS online_projects,
    ( SELECT count(DISTINCT cf.user_id) AS count
           FROM public.category_followers cf
          WHERE (cf.category_id = c.id)) AS followers
   FROM ((public.categories c
     LEFT JOIN public.projects p ON ((p.category_id = c.id)))
     LEFT JOIN public.flexible_projects fp ON ((fp.project_id = p.id)))
  GROUP BY c.id;

GRANT SELECT on "1".categories TO admin, web_user, anonymous;
    SQL
  end
end
