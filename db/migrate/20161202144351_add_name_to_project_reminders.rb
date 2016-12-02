class AddNameToProjectReminders < ActiveRecord::Migration
  def change
    execute <<-SQL
    CREATE OR REPLACE VIEW "1".project_reminders as
    SELECT pr.project_id,
    pr.user_id,
    p.name as project_name,
    not exists(
    select true from project_notifications pn
    where pn.user_id = pr.user_id
    and pn.project_id = pr.project_id
    and template_name = 'reminder'
    ) as without_notification
   FROM project_reminders pr
   join projects p on pr.project_id  = p.id
  WHERE is_owner_or_admin(pr.user_id);
    SQL
  end
end
