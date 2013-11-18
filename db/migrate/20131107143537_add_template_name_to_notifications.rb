class AddTemplateNameToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :template_name, :text
  end
end
