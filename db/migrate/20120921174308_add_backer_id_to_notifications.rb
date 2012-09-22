class AddBackerIdToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :backer_id, :integer
    add_foreign_key :notifications, :backers
  end
end
