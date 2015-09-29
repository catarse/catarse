class CreateCategoriesView < ActiveRecord::Migration
  def change
    create_table :categories_views do |t|
      execute "
      CREATE OR REPLACE VIEW \"1\".categories AS
        SELECT c.id,
           name_pt,
           name_en,
           (SELECT count(*) from projects p where p.state = 'online' AND p.category_id = c.id) as online_projects,
           (SELECT count(DISTINCT user_id) from category_followers cf where cf.category_id = c.id) as followers

         FROM categories c
         WHERE
          exists(select true from projects p where p.category_id = c.id and p.state not in('draft', 'rejected'));

      grant select on \"1\".categories to admin;
      grant select on \"1\".categories to web_user;
      grant select on \"1\".categories to anonymous;

      CREATE OR REPLACE FUNCTION public.following_category(\"1\".categories)
       RETURNS boolean
       LANGUAGE sql
       STABLE SECURITY DEFINER
      AS $function$
        SELECT EXISTS(SELECT true from category_followers cf WHERE cf.category_id = $1.id AND cf.user_id = nullif(current_setting('user_vars.user_id'), '')::int)
      $function$;

      "
    end
  end
end
