class RemoveCreditsFromUserTotals < ActiveRecord::Migration
  def change
    execute <<-SQL
      select deps_save_and_drop_dependencies('1', 'user_totals');
      DROP MATERIALIZED VIEW "1".user_totals;

      CREATE VIEW "1".user_totals AS
      SELECT u.id,
          u.id as user_id,
          coalesce(ct.total_contributed_projects, 0) as total_contributed_projects,
          coalesce(ct.sum, 0) as sum,
          coalesce(ct.count, 0) as count,
          coalesce(( SELECT count(*) AS count
              FROM projects p2
              WHERE is_published(p2.*) AND p2.user_id = u.id), 0) AS total_published_projects
      FROM users u
          LEFT JOIN (
      SELECT
          c.user_id,
          count(DISTINCT c.project_id) AS total_contributed_projects,
          sum(pa.value) AS sum,
          count(DISTINCT c.id) AS count
              FROM
          contributions c
          JOIN payments pa ON c.id = pa.contribution_id
          JOIN projects p ON c.project_id = p.id
      WHERE pa.state = ANY (confirmed_states())
      GROUP BY c.user_id
          ) ct ON u.id = ct.user_id;


      select deps_restore_dependencies('1', 'user_totals');
      grant select on "1".user_totals to anonymous;
      grant select on "1".user_totals to admin;
      grant select on "1".user_totals to web_user;
    SQL
  end
end
