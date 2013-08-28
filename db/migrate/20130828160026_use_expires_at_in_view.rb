class UseExpiresAtInView < ActiveRecord::Migration
  def up
    execute "CREATE or replace VIEW financial_reports AS
      SELECT p.name, u.moip_login, p.goal, p.expires_at, p.state FROM (projects p JOIN users u ON ((u.id = p.user_id)));"
  end

  def down
  end
end
