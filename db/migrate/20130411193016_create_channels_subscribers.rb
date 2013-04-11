class CreateChannelsSubscribers < ActiveRecord::Migration
  def up
    create_table :channels_subscribers do |t|
      t.integer :user_id, null: false
      t.integer :channel_id, null: false
    end
    add_index :channels_subscribers, [:user_id, :channel_id], unique: true
  end

  def down
    drop_table :channels_subscribers
  end
end
