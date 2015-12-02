class AdjustProjectRemindersTriggers < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE OR REPLACE FUNCTION insert_project_reminder() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        declare
          reminder "1".project_reminders;
        begin
          select
            pr.project_id,
            pr.user_id
          from public.project_reminders pr
          where
            pr.user_id = current_user_id()
            and pr.project_id = NEW.project_id
          into reminder;

          if found then
            return reminder;
          end if;

          insert into public.project_reminders (user_id, project_id) values (current_user_id(), NEW.project_id);

          return new;
        end;
      $$;

CREATE OR REPLACE FUNCTION delete_project_reminder() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        begin
          delete from public.project_reminders
          where
            user_id = current_user_id()
            and project_id = OLD.project_id;

          return old;
        end;
      $$;

grant insert, select, delete on public.project_reminders to web_user;
grant insert, select, delete on public.project_reminders to admin;

grant usage on sequence project_reminders_id_seq to web_user;
grant usage on sequence project_reminders_id_seq to admin;
    SQL
  end

  def down
    execute <<-SQL
revoke insert, select, delete on public.project_reminders from web_user;
revoke insert, select, delete on public.project_reminders from admin;

revoke usage on sequence project_reminders_id_seq from web_user;
revoke usage on sequence project_reminders_id_seq from admin;

CREATE OR REPLACE FUNCTION insert_project_reminder() RETURNS trigger
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


CREATE OR REPLACE FUNCTION delete_project_reminder() RETURNS trigger
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


    SQL
  end
end
