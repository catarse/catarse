class AddMetadataToDirectMessages < ActiveRecord::Migration[4.2]
  def change
    add_column :direct_message_notifications, :metadata, :jsonb, null: false, default: '{}'
  end
end
