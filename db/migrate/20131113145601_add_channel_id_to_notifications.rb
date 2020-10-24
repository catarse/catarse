class AddChannelIdToNotifications < ActiveRecord::Migration[4.2]
  def change
    add_column :notifications, :channel_id, :integer
  end
end
