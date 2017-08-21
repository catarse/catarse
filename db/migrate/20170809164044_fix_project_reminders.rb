class FixProjectReminders < ActiveRecord::Migration
  def change
    execute <<-SQL
  create or replace view "1".project_reminders as
  SELECT pr.project_id,
      pr.user_id,
      p.name AS project_name,
      NOT (EXISTS ( SELECT true AS bool
             FROM project_notifications pn
            WHERE pn.user_id = pr.user_id AND pn.project_id = pr.project_id AND pn.template_name = 'reminder'::text)) AS without_notification
     FROM project_reminders pr
       JOIN projects p ON pr.project_id = p.id
      where is_owner_or_admin(pr.user_id) and not p.is_expired ;
    SQL
  end
end
