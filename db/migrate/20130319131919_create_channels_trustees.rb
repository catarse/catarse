class CreateChannelsTrustees < ActiveRecord::Migration[4.2]
  def up
    create_table :channels_trustees do |t|
      t.integer :user_id
      t.integer :channel_id, index: true
    end

    add_index :channels_trustees, %i[user_id channel_id], unique: true
  end

  def down
    drop_table :channels_trustees
  end
end
