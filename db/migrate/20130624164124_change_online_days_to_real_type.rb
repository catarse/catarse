class ChangeOnlineDaysToRealType < ActiveRecord::Migration
  def up
    drop_view :financial_reports
    execute "ALTER TABLE projects ALTER COLUMN online_days SET DATA TYPE REAL;"
    execute"CREATE or replace VIEW financial_reports AS
    SELECT p.name, u.moip_login, p.goal, p.online_date + (p.online_days::text||' days')::interval as expires_at, p.state FROM (projects p JOIN users u ON ((u.id = p.user_id)));"
  end

  def down
  end
end
