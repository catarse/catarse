class DropTanimotoTables < ActiveRecord::Migration
  def change
    execute <<-SQL
    drop view IF EXISTS "1".recommend_projects2user;
    DROP VIEW IF EXISTS public.recommend_projects2user;
    DROP VIEW IF EXISTS public.recommend_tanimoto_users;
    DROP MATERIALIZED VIEW IF EXISTS  public.recommend_tanimoto_user_visited;
    DROP MATERIALIZED VIEW IF EXISTS public.recommend_tanimoto_user_reminders;
    DROP MATERIALIZED VIEW IF EXISTS public.recommend_tanimoto_user_contributions;
    DROP MATERIALIZED VIEW IF EXISTS public.recommend_users;
    DROP MATERIALIZED VIEW IF EXISTS public.recommend_tanimoto_projects;
    DROP MATERIALIZED VIEW IF EXISTS public.recommend_projects;
    DROP TABLE IF EXISTS public.recommend_projects_blacklist;
    SQL
  end
end
