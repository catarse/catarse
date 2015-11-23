class RefactorDatabaseUserId < ActiveRecord::Migration
  def change
    execute <<-SQL
CREATE OR REPLACE FUNCTION public.current_user_id() RETURNS int
    LANGUAGE sql
    AS $_$
        SELECT nullif(current_setting('user_vars.user_id'), '')::integer;
      $_$;

CREATE OR REPLACE FUNCTION public.current_user_already_in_reminder(projects) RETURNS boolean
    LANGUAGE sql
    AS $_$
        select public.user_has_reminder_for_project(current_user_id(), $1.id);
      $_$;

CREATE OR REPLACE FUNCTION public.current_user_has_contributed_to_project(integer) RETURNS boolean
    LANGUAGE sql STABLE
    AS $_$
        select public.user_has_contributed_to_project(current_user_id(), $1);
      $_$;

CREATE OR REPLACE FUNCTION public.delete_project_reminder() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        begin
          delete from public.project_notifications
          where
            template_name = 'reminder'
            and user_id = current_user_id()
            and project_id = OLD.project_id;
          return old;
        end;
      $$;

CREATE OR REPLACE FUNCTION public.insert_project_reminder() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        declare
          reminder "1".project_reminders;
        begin
          select
            pn.project_id,
            pn.user_id
          from public.project_notifications pn
          where
            pn.template_name = 'reminder'
            and pn.user_id = current_user_id()
            and pn.project_id = NEW.project_id
          into reminder;

          if found then
            return reminder;
          end if;

          insert into public.project_notifications (user_id, project_id, template_name, deliver_at, locale, from_email, from_name)
          values (current_user_id(), NEW.project_id, 'reminder', (
            select p.expires_at - '48 hours'::interval from projects p where p.id = NEW.project_id
          ), 'pt', settings('email_contact'), settings('company_name'));

          return new;
        end;
      $$;

CREATE OR REPLACE FUNCTION public.is_owner_or_admin(integer) RETURNS boolean
    LANGUAGE sql STABLE
    AS $_$
              SELECT
                current_user_id() = $1
                OR current_user = 'admin';
            $_$;

CREATE OR REPLACE FUNCTION public.near_me("1".projects) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
          SELECT
      COALESCE($1.state_acronym, (SELECT pa.address_state FROM project_accounts pa WHERE pa.project_id = $1.project_id)) = (SELECT u.address_state FROM users u WHERE u.id = current_user_id())
        $_$;
    SQL
  end
end
