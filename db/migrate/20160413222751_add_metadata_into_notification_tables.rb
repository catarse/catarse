class AddMetadataIntoNotificationTables < ActiveRecord::Migration
  def change
    add_column :contribution_notifications, :metadata, :jsonb, null: false, default: '{}'
    add_column :project_notifications, :metadata, :jsonb, null: false, default: '{}'
    add_column :user_notifications, :metadata, :jsonb, null: false, default: '{}'
    add_column :category_notifications, :metadata, :jsonb, null: false, default: '{}'
    add_column :project_post_notifications, :metadata, :jsonb, null: false, default: '{}'
    add_column :user_transfer_notifications, :metadata, :jsonb, null: false, default: '{}'
    add_column :donation_notifications, :metadata, :jsonb, null: false, default: '{}'
  end
end
