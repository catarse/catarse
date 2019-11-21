class ProjectReportExportView < ActiveRecord::Migration
  def up
    execute <<-SQL

    CREATE OR REPLACE VIEW "1"."project_report_exports" AS 
      SELECT
          proj_export.*
      FROM project_report_exports proj_export
      LEFT JOIN projects proj
      ON proj.id = proj_export.project_id
      WHERE is_owner_or_admin(proj.user_id) OR proj.user_id = current_user_id()
    ;

    grant select on "1".project_report_exports to web_user;
    grant select on "1".project_report_exports to admin;

    SQL
  end

  def down
    execute <<-SQL

    DROP VIEW "1"."project_report_exports";

    SQL
  end
end
