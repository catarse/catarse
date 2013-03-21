class CreateChannelsTrustees < ActiveRecord::Migration
  def up
    create_table :channels_trustees do |t|
      t.integer :user_id, index: { with: :channel_id, unique: true }
      t.integer :channel_id, index: true
    end
  end

  def down
    drop_table :channels_trustees
  end
end
