class AddChannelPostOnNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :channel_post_id, :integer
  end
end
