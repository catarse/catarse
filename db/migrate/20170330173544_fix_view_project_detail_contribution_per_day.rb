class FixViewProjectDetailContributionPerDay < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE VIEW "1".project_contributions_per_day AS
      SELECT i.project_id,
            json_agg( json_build_object('paid_at', i.created_at, 'created_at', i.created_at, 'total', i.total, 'total_amount', i.total_amount) ) AS source
      FROM
        (SELECT c.project_id,
                p.created_at::date AS created_at,
                count(c) AS total,
                sum(c.value) AS total_amount
        FROM contributions c
        JOIN payments p ON p.contribution_id = c.id
        WHERE p.paid_at IS NOT NULL
          AND c.was_confirmed
        GROUP BY p.created_at::date,
                 c.project_id
        ORDER BY p.created_at::date ASC) AS i
      GROUP BY i.project_id;

      GRANT SELECT ON "1".project_contributions_per_day TO anonymous;
      GRANT SELECT ON "1".project_contributions_per_day TO web_user;
      GRANT SELECT ON "1".project_contributions_per_day TO ADMIN;
    SQL
  end

  def down
    execute <<-SQL
      create or replace view "1".project_contributions_per_day as
        select
          i.project_id,
          json_agg(
            json_build_object('paid_at', i.paid_at, 'total', i.total, 'total_amount', i.total_amount)
          ) as source
        from (select
        c.project_id,
        p.paid_at::date as paid_at,
        count(c) as total,
        sum(c.value) as total_amount
        from contributions c
        join payments p on p.contribution_id = c.id
        where c.was_confirmed and p.paid_at is not null
        group by p.paid_at::date, c.project_id
        order by p.paid_at::date asc) as i
        group by i.project_id;

      grant select on "1".project_contributions_per_day to anonymous;
      grant select on "1".project_contributions_per_day to web_user;
      grant select on "1".project_contributions_per_day to admin;
    SQL
  end
end
