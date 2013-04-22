class AddNotificationTypeProjectReceivedChannel < ActiveRecord::Migration
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
