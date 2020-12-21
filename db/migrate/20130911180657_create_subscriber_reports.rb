class CreateSubscriberReports < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL
      CREATE OR REPLACE VIEW subscriber_reports AS
      SELECT u.id, cs.channel_id, u.name, u.email
      FROM users u JOIN channels_subscribers cs ON cs.user_id = u.id
    SQL
  end
end
