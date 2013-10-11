class DropChannelsTrustees < ActiveRecord::Migration
  def change
    drop_table :channels_trustees
  end
end
