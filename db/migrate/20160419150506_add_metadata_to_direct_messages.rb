class AddMetadataToDirectMessages < ActiveRecord::Migration
  def change
    add_column :direct_message_notifications, :metadata, :jsonb, null: false, default: '{}'
  end
end
