class RemoveExpiresAtFromViews < ActiveRecord::Migration
  def up
    execute"CREATE or replace VIEW financial_reports AS
    SELECT p.name, u.moip_login, p.goal, p.online_date + (p.online_days::text||' days')::interval as expires_at, p.state FROM (projects p JOIN users u ON ((u.id = p.user_id)));"
  end

  def down
    execute"CREATE or replace VIEW financial_reports AS
    SELECT p.name, u.moip_login, p.goal, p.online_date + (p.online_days::text||' days')::interval as expires_at, p.state FROM (projects p JOIN users u ON ((u.id = p.user_id)));"
  end
end
