class AddIndexesToNotifications < ActiveRecord::Migration
  def change
    add_index :notifications, [:user_id, :template_name]
    add_index :notifications, [:backer_id, :template_name]
    add_index :notifications, [:project_id, :template_name]
  end
end
