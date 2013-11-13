class AddChannelIdToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :channel_id, :integer
  end
end
