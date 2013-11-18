class AddOriginEmailToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :origin_email, :text
  end
end
