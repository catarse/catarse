class DropNotifications < ActiveRecord::Migration[4.2]
  def change
    drop_table :notifications
  end
end
