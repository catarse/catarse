class MigrateReminders < ActiveRecord::Migration
  def up
    execute " set statement_timeout to 0;"
    execute <<-SQL
INSERT INTO public.project_reminders (user_id, project_id, created_at, updated_at)
  SELECT user_id, project_id, max(created_at), max(updated_at)
  FROM project_notifications
  WHERE template_name = 'reminder'
  GROUP BY project_id, user_id
    SQL
  end

  def down
    execute "truncate table public.project_remiders"
  end
end
