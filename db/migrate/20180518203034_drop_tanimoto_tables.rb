class DropTanimotoTables < ActiveRecord::Migration
  def change
    execute <<-SQL
    drop view "1".recommend_projects2user;
    DROP VIEW public.recommend_projects2user;
    DROP VIEW public.recommend_tanimoto_users;
    DROP MATERIALIZED VIEW public.recommend_tanimoto_user_visited;
    DROP MATERIALIZED VIEW public.recommend_tanimoto_user_reminders;
    DROP MATERIALIZED VIEW public.recommend_tanimoto_user_contributions;
    DROP MATERIALIZED VIEW public.recommend_users;
    DROP MATERIALIZED VIEW public.recommend_tanimoto_projects;
    DROP MATERIALIZED VIEW public.recommend_projects;
    DROP TABLE public.recommend_projects_blacklist;
    SQL
  end
end
