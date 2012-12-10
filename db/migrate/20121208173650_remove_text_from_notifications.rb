class RemoveTextFromNotifications < ActiveRecord::Migration
  def up
    remove_column :notifications, :text
  end

  def down
    add_column :notifications, :text, :text
  end
end
