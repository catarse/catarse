class AddNotificationUpdateIdIndex < ActiveRecord::Migration
  def up
    add_index :notifications, :update_id
  end

  def down
    remove_index :notifications, :update_id
  end
end
