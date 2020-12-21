class AddLayoutToNotificationType < ActiveRecord::Migration[4.2]
  def change
    add_column :notification_types, :layout, :text, null: false, default: 'email'
  end
end
