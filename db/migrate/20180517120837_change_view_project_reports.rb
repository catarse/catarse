class ChangeViewProjectReports < ActiveRecord::Migration[4.2]
  def up
    execute %Q{
      DROP VIEW "1"."project_reports";
      CREATE OR REPLACE VIEW "1"."project_reports" AS
      SELECT project_reports.id,
             project_reports.project_id,
             project_reports.user_id,
             project_reports.reason,
             project_reports.email,
             project_reports.details,
             project_reports.data,
             project_reports.created_at,
             project_reports.updated_at
      FROM public.project_reports as project_reports
      WHERE is_owner_or_admin(project_reports.user_id);

      grant select on public.project_reports to admin, postgrest;
      grant select on "1"."project_reports" to admin, postgrest;

      CREATE TRIGGER insert_project_report INSTEAD OF INSERT ON "1".project_reports FOR EACH ROW EXECUTE PROCEDURE insert_project_report();

      GRANT SELECT ON public.settings TO web_user, anonymous, admin;
      GRANT SELECT ON public.users TO web_user, anonymous, admin;
      grant insert, select on "1".project_reports to anonymous;
      grant insert, select on "1".project_reports to web_user;
      grant insert, select on "1".project_reports to admin;
      grant insert, select on public.project_reports to anonymous;
      grant insert, select on public.project_reports to web_user;
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

    }
  end

  def down
    execute %Q{
      DROP VIEW "1"."project_reports";
      CREATE OR REPLACE VIEW "1"."project_reports" AS
      SELECT project_reports.id,
             project_reports.project_id,
             project_reports.user_id,
             project_reports.reason,
             project_reports.email,
             project_reports.details,
             project_reports.created_at,
             project_reports.updated_at
      FROM public.project_reports as project_reports
      WHERE is_owner_or_admin(project_reports.user_id);

      grant select on public.project_reports to admin, postgrest;
      grant select on "1"."project_reports" to admin, postgrest;

      CREATE TRIGGER insert_project_report INSTEAD OF INSERT ON "1".project_reports FOR EACH ROW EXECUTE PROCEDURE insert_project_report();

      GRANT SELECT ON public.settings TO web_user, anonymous, admin;
      GRANT SELECT ON public.users TO web_user, anonymous, admin;
      grant insert, select on "1".project_reports to anonymous;
      grant insert, select on "1".project_reports to web_user;
      grant insert, select on "1".project_reports to admin;
      grant insert, select on public.project_reports to anonymous;
      grant insert, select on public.project_reports to web_user;
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

    }
  end
end
