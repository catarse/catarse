class AddOriginNameToNotifications < ActiveRecord::Migration[4.2]
  def change
    add_column :notifications, :origin_name, :text
  end
end
