class AddNotificationTypeDraftChannel < ActiveRecord::Migration
  def up
    execute "
    INSERT INTO notification_types (name, created_at, updated_at) VALUES ('new_draft_project_channel', now(), now())
    "
  end

  def down
    execute "
    DELETE FROM notification_types WHERE name = 'new_draft_project_channel'
    "
  end
end
