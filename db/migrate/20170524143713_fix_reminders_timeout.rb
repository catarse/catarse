class FixRemindersTimeout < ActiveRecord::Migration
  def change
    execute <<-SQL

    DROP INDEX if exists index_project_notifications_user_project_template;

    CREATE  INDEX index_project_notifications_user_project_template ON project_notifications USING btree (user_id, project_id, template_name) ;

    CREATE OR REPLACE FUNCTION can_deliver(project_reminders) RETURNS boolean
        LANGUAGE sql STABLE SECURITY DEFINER
        AS $_$
    select exists (
    select true from projects p
    where p.expires_at is not null
    and p.id = $1.project_id
    and p.state = 'online'
    and public.is_past((p.expires_at - '48 hours'::interval))
    );
    $_$;
    
    SQL
  end
end
