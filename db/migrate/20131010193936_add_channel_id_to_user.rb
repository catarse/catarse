class AddChannelIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :channel_id, :integer
  end
end
