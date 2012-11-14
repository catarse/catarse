class AddForeignKeysToUnsubscribes < ActiveRecord::Migration
  def change
    add_foreign_key :unsubscribes, :users
    add_foreign_key :unsubscribes, :notification_types
    add_foreign_key :unsubscribes, :projects
  end
end
