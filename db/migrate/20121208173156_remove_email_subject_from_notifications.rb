class RemoveEmailSubjectFromNotifications < ActiveRecord::Migration
  def up
    remove_column :notifications, :email_subject
  end

  def down
    add_column :notifications, :email_subject, :text
  end
end
