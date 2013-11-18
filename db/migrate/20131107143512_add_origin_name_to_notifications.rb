class AddOriginNameToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :origin_name, :text
  end
end
