class ChangeInsertProjectReport < ActiveRecord::Migration[4.2]
  def up
    execute %Q{
      CREATE OR REPLACE FUNCTION public.insert_project_report()
      RETURNS trigger
      LANGUAGE plpgsql
      AS $function$
      declare
      project_report "1".project_reports;
      cur_user_id integer;
      begin
        cur_user_id := current_user_id();
        NEW.user_id := cur_user_id;

        insert into public.project_reports (
                      user_id,
                      project_id,
                      email,
                      reason,
                      details,
                      data,
                      created_at,
                      updated_at
                    )
        values (
          cur_user_id,
          NEW.project_id,
          NEW.email,
          NEW.reason,
          NEW.details,
          NEW.data,
          current_timestamp,
          current_timestamp
        );
        return new;
      end;
      $function$
      ;
    }
  end

  def down
    execute %Q{
      CREATE OR REPLACE FUNCTION public.insert_project_report()
      RETURNS trigger
      LANGUAGE plpgsql
      AS $function$
      declare
      project_report "1".project_reports;
      cur_user_id integer;
      begin
        cur_user_id := current_user_id();
        NEW.user_id := cur_user_id;

        insert into public.project_reports (
                      user_id,
                      project_id,
                      email,
                      reason,
                      details,
                      created_at,
                      updated_at
                    )
        values (
          cur_user_id,
          NEW.project_id,
          NEW.email,
          NEW.reason,
          NEW.details,
          current_timestamp,
          current_timestamp
        );
        return new;
      end;
      $function$
      ;
    }
  end
end
