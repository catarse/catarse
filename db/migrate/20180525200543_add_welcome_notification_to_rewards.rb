class AddWelcomeNotificationToRewards < ActiveRecord::Migration[4.2]
  def change
    add_column :rewards, :welcome_message_subject, :text
    add_column :rewards, :welcome_message_body, :text
  end
end
