class AddNotificationTypeProjectReceivedChannel < ActiveRecord::Migration[4.2]
  def up
    execute "
    INSERT INTO notification_types (name, created_at, updated_at) VALUES ('project_received_channel', now(), now())
    "
  end

  def down
    execute "
    DELETE FROM notification_types WHERE name = 'project_received_channel'
    "
  end
end
