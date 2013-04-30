class AddLayoutToNotificationType < ActiveRecord::Migration
  def change
    add_column :notification_types, :layout, :text, null: false, default: 'email'
  end
end
