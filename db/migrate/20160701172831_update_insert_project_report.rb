class UpdateInsertProjectReport < ActiveRecord::Migration
  def change
    execute <<-SQL
      CREATE OR REPLACE FUNCTION insert_project_report() RETURNS trigger
          LANGUAGE plpgsql
          AS $$
              declare
                project_report "1".project_reports;
              begin
                insert into public.project_reports (user_id, project_id, email, reason, details, created_at, updated_at) values
                                                  (NEW.user_id, NEW.project_id, NEW.email, NEW.reason, NEW.details, current_timestamp, current_timestamp);
                return new;
              end;
            $$;

    CREATE OR REPLACE FUNCTION send_project_report() RETURNS trigger
        LANGUAGE plpgsql
        AS $$
        BEGIN
            INSERT INTO project_report_notifications(user_id, project_report_id, from_email, from_name, template_name, locale, created_at, updated_at ) VALUES
                                                    ((select id from users where email = (select value from settings where name = 'email_projects' limit 1)), new.id, new.email, '', 'project_report', 'pt', current_timestamp, current_timestamp );
            RETURN NEW;
        END;
        $$;
    SQL
  end
end
