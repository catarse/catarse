class AddWelcomeNotificationToRewards < ActiveRecord::Migration
  def change
    add_column :rewards, :welcome_message_subject, :text
    add_column :rewards, :welcome_message_body, :text
  end
end
