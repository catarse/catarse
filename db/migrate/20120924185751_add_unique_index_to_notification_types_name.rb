class AddUniqueIndexToNotificationTypesName < ActiveRecord::Migration
  def change
    add_index :notification_types, :name, :unique => true
  end
end
