class MigrateDeleteProjectReminder < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE OR REPLACE FUNCTION public.delete_project_reminder()
    RETURNS trigger
    LANGUAGE plv8
    AS $function$
        var sql = "delete from public.project_notifications " +
            "where " +
                "template_name = 'reminder' " +
                "and user_id = nullif(current_setting('user_vars.user_id'), '')::integer " +
                "and project_id = $1";
        plv8.execute(sql, [OLD.project_id]);
        return OLD;
    $function$
    SQL
  end

  def down
    execute <<-SQL
    CREATE OR REPLACE FUNCTION public.delete_project_reminder()
    RETURNS trigger
    LANGUAGE plpgsql
    AS $function$
            begin
            delete from public.project_notifications
            where
                template_name = 'reminder'
                and user_id = current_setting('user_vars.user_id')::integer
                and project_id = OLD.project_id;
            return old;
            end;
    $function$
    SQL
  end
end
