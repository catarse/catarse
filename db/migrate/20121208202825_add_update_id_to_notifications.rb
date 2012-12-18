class AddUpdateIdToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :update_id, :integer
    add_foreign_key :notifications, :updates
  end
end
