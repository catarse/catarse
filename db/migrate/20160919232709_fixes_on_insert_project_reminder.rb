class FixesOnInsertProjectReminder < ActiveRecord::Migration
  def up
  execute %Q{
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

          insert into public.project_reminders (user_id, project_id, created_at) values (current_user_id(), NEW.project_id, now());

          return new;
        end;
      $$;


  }
  end

  def down
  execute %Q{
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
  }
  end
end
