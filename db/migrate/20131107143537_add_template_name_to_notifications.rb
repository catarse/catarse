class AddTemplateNameToNotifications < ActiveRecord::Migration[4.2]
  def change
    add_column :notifications, :template_name, :text
  end
end
