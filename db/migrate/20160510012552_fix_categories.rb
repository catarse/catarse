class FixCategories < ActiveRecord::Migration
  def change
    execute <<-SQL
    CREATE OR REPLACE VIEW "1".categories as
    SELECT c.id,
    c.name_pt AS name,
    count(DISTINCT p.id) FILTER (WHERE is_current_and_online(p.expires_at, p.state::text)) AS online_projects,
    ( SELECT count(DISTINCT cf.user_id) AS count
           FROM category_followers cf
          WHERE cf.category_id = c.id) AS followers,
    (EXISTS ( SELECT true AS bool
           FROM category_followers cf
          WHERE cf.category_id = c.id AND cf.user_id = current_user_id())) AS following
   FROM categories c
     LEFT JOIN projects p ON p.category_id = c.id
  GROUP BY c.id;
    SQL
  end
end
