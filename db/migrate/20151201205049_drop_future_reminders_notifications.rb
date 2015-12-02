class DropFutureRemindersNotifications < ActiveRecord::Migration
  def up
    execute " set statement_timeout to 0;"
    execute <<-SQL
delete from project_notifications pn
where pn.deliver_at > current_timestamp
and exists( select true from project_reminders pr
 where pr.user_id = pn.user_id and pr.project_id = pn.project_id)
and template_name = 'reminder'
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
