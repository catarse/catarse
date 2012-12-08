class RemoveFacebookTextFromNotifications < ActiveRecord::Migration
  def up
    remove_column :notifications, :facebook_text
  end

  def down
    add_column :notifications, :facebook_text, :text
  end
end
