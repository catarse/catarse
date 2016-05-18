class CreateProjectReportTriggers < ActiveRecord::Migration
  def change
    execute <<-SQL
    CREATE FUNCTION send_project_report() RETURNS trigger
        LANGUAGE plpgsql
        AS $$
        BEGIN
            INSERT INTO project_report_notifications(user_id, project_report_id, from_email, from_name, template_name, locale, created_at, updated_at ) VALUES
                                                    (new.user_id, new.id, new.email, '', 'project_report', 'pt', current_timestamp, current_timestamp );
            RETURN NEW;
        END;
        $$;
    CREATE TRIGGER send_project_report AFTER INSERT ON project_reports FOR EACH ROW EXECUTE PROCEDURE send_project_report();
    CREATE TRIGGER system_notification_dispatcher AFTER INSERT ON public.project_report_notifications FOR EACH ROW EXECUTE PROCEDURE public.system_notification_dispatcher();

    CREATE VIEW "1".project_reports AS 
    SELECT user_id, reason, project_id, email, details
    from project_reports;


      CREATE OR REPLACE FUNCTION insert_project_report() RETURNS trigger
          LANGUAGE plpgsql
          AS $$
              declare
                project_report "1".project_reports;
              begin
                insert into public.project_reports (user_id, project_id, email, reason, details, created_at, updated_at) values
                                                  ((select id from users where email = (select value from settings where name = 'email_projects' limit 1)), NEW.project_id, NEW.email, NEW.reason, NEW.details, current_timestamp, current_timestamp);
                return new;
              end;
            $$;

      create trigger insert_project_report instead of insert on "1".project_reports
        for each row execute procedure public.insert_project_report();

      GRANT SELECT ON public.settings TO web_user, anonymous, admin;
      GRANT SELECT ON public.users TO web_user, anonymous, admin;
      grant insert on "1".project_reports to anonymous;
      grant insert on "1".project_reports to web_user;
      grant insert, select on "1".project_reports to admin;
      grant insert on public.project_reports to anonymous;
      grant insert on public.project_reports to web_user;
      grant insert, select on public.project_reports to admin;
      grant insert on public.project_report_notifications to anonymous;
      grant insert on public.project_report_notifications to web_user;
      grant insert, select on public.project_report_notifications to admin;
      grant usage on sequence project_reports_id_seq to anonymous;
      grant usage on sequence project_reports_id_seq to web_user;
      grant usage on sequence project_reports_id_seq to admin;
      grant usage on sequence project_report_notifications_id_seq to anonymous;
      grant usage on sequence project_report_notifications_id_seq to web_user;
      grant usage on sequence project_report_notifications_id_seq to admin;
    SQL
  end
end
