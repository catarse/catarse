class RemoveEmailTextFromNotifications < ActiveRecord::Migration
  def up
    remove_column :notifications, :email_text
  end

  def down
    add_column :notifications, :email_text, :text
  end
end
