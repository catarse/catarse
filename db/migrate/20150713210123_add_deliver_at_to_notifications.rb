class AddDeliverAtToNotifications < ActiveRecord::Migration
  def up
    add_column :category_notifications, :deliver_at, :timestamp
    add_column :channel_post_notifications, :deliver_at, :timestamp
    add_column :contribution_notifications, :deliver_at, :timestamp
    add_column :project_notifications, :deliver_at, :timestamp
    add_column :project_post_notifications, :deliver_at, :timestamp
    add_column :user_notifications, :deliver_at, :timestamp

    execute "ALTER TABLE category_notifications ALTER deliver_at SET DEFAULT current_timestamp"
    execute "ALTER TABLE channel_post_notifications ALTER deliver_at SET DEFAULT current_timestamp"
    execute "ALTER TABLE contribution_notifications ALTER deliver_at SET DEFAULT current_timestamp"
    execute "ALTER TABLE project_notifications ALTER deliver_at SET DEFAULT current_timestamp"
    execute "ALTER TABLE project_post_notifications ALTER deliver_at SET DEFAULT current_timestamp"
    execute "ALTER TABLE user_notifications ALTER deliver_at SET DEFAULT current_timestamp"
  end

  def down
    remove_column :category_notifications, :deliver_at
    remove_column :channel_post_notifications, :deliver_at
    remove_column :contribution_notifications, :deliver_at
    remove_column :project_notifications, :deliver_at
    remove_column :project_post_notifications, :deliver_at
    remove_column :user_notifications, :deliver_at
  end
end
