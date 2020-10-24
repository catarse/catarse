class AddLocaleToNotifications < ActiveRecord::Migration[4.2]
  def change
    add_column :notifications, :locale, :text
  end
end
