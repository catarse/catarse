class AlterTimestampToIncludeTimezone < ActiveRecord::Migration
  def up
    execute "
      DROP FUNCTION if exists expires_at(projects);
      drop VIEW if exists financial_reports ;
      ALTER TABLE projects ALTER COLUMN online_date set data type timestamp with time zone;
      CREATE OR REPLACE FUNCTION expires_at(projects) RETURNS timestamptz AS $$
       SELECT (($1.online_date AT TIME ZONE coalesce((SELECT value FROM configurations WHERE name = 'timezone'), 'America/Sao_Paulo') + ($1.online_days || ' days')::interval)::date::text || ' 23:59:59')::timestamptz
      $$ LANGUAGE SQL;
      CREATE or replace VIEW financial_reports AS
      SELECT p.name, u.moip_login, p.goal, ((p.online_date + (p.online_days||' days')::interval)::date::text || ' 23:59:59') as expires_at, p.state FROM (projects p JOIN users u ON ((u.id = p.user_id)));
    "
  end

  def down
  end
end
