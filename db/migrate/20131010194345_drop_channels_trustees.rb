class DropChannelsTrustees < ActiveRecord::Migration[4.2]
  def change
    drop_table :channels_trustees
  end
end
