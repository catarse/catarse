class CreateCategoriesEndpoint < ActiveRecord::Migration
  def change
    execute <<-SQL
    CREATE OR REPLACE VIEW "1".categories AS
    SELECT
        c.id,
        name_pt as name,
        (SELECT count(*) from projects p where p.state = 'online' AND p.category_id = c.id) as online_projects,
        (SELECT count(DISTINCT user_id) from category_followers cf where cf.category_id = c.id) as followers
        FROM categories c
        WHERE
        exists(select true from projects p where p.category_id = c.id and p.state not in('draft', 'rejected'));
    grant select on "1".categories to admin;
    grant select on "1".categories to web_user;
    grant select on "1".categories to anonymous;
    SQL
  end
end
