class AddLocaleToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :locale, :text
  end
end
