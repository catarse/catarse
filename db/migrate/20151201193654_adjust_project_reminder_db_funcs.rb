class AdjustProjectReminderDbFuncs < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE OR REPLACE FUNCTION user_has_reminder_for_project(user_id integer, project_id integer) RETURNS boolean
    LANGUAGE sql SECURITY DEFINER
    AS $_$
        select exists (select true from public.project_reminders pr where pr.user_id = $1 and pr.project_id = $2);
      $_$;

CREATE OR REPLACE VIEW "1".project_reminders AS
 SELECT pr.project_id,
    pr.user_id
   FROM public.project_reminders pr
  WHERE public.is_owner_or_admin(pr.user_id);

    SQL
  end

  def down
    execute <<-SQL
CREATE OR REPLACE FUNCTION user_has_reminder_for_project(user_id integer, project_id integer) RETURNS boolean
    LANGUAGE sql SECURITY DEFINER
    AS $_$
        select exists (select true from project_notifications pn where pn.template_name = 'reminder' and pn.user_id = $1 and pn.project_id = $2);
      $_$;

CREATE OR REPLACE VIEW "1".project_reminders AS
 SELECT pn.project_id,
    pn.user_id
   FROM public.project_notifications pn
  WHERE ((pn.template_name = 'reminder'::text) AND public.is_owner_or_admin(pn.user_id));

    SQL
  end
end
