class RemoveTwitterTextFromNotifications < ActiveRecord::Migration
  def up
    remove_column :notifications, :twitter_text
  end

  def down
    add_column :notifications, :twitter_text, :text
  end
end
