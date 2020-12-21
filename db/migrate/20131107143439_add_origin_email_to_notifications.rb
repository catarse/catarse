class AddOriginEmailToNotifications < ActiveRecord::Migration[4.2]
  def change
    add_column :notifications, :origin_email, :text
  end
end
