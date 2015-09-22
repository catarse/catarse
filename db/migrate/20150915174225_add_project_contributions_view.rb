class AddProjectContributionsView < ActiveRecord::Migration
  def up
    execute <<-SQL
      create view "1".project_contributions as
        select
          c.anonymous,
          c.project_id as project_id,
          c.id,
          u.profile_img_thumbnail as profile_img_thumbnail,
          u.id as user_id,
          u.name as user_name,
          (
            case
            when public.is_owner_or_admin(p.user_id) then c.value
            else null end
          ) as value,
          pa.waiting_payment,
          public.is_owner_or_admin(p.user_id) as is_owner_or_admin,
          ut.total_contributed_projects,
          c.created_at
        from contributions c
        join users u on c.user_id = u.id
        join projects p on p.id = c.project_id
        join payments pa on pa.contribution_id = c.id
        left join "1".user_totals ut on ut.user_id = u.id
        where (c.was_confirmed or pa.waiting_payment) and (not c.anonymous or public.is_owner_or_admin(p.user_id)); -- or c.waiting_payment;

      grant select on "1".project_contributions to admin;
      grant select on "1".project_contributions to web_user;
      grant select on "1".project_contributions to anonymous;
    SQL
  end

  def down
    execute <<-SQL
      drop view "1".project_contributions;
    SQL
  end
end
