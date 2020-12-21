class AddChannelPostOnNotification < ActiveRecord::Migration[4.2]
  def change
    add_column :notifications, :channel_post_id, :integer
  end
end
