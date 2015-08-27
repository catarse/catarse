class ViewProjectDetailContributionPerDay < ActiveRecord::Migration
  def up
    execute <<-SQL
      create view "1".project_contributions_per_day as
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

  def down
    execute <<-SQL
      drop view "1".project_contributions_per_day
    SQL
  end
end
