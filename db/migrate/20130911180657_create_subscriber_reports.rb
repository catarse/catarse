class CreateSubscriberReports < ActiveRecord::Migration
  def change
    create_view(:subscriber_reports, 
      "SELECT u.id, cs.channel_id, u.name, u.email
      FROM users u JOIN channels_subscribers cs ON cs.user_id = u.id"
    )
  end
end
