class AddFollowersSubToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :subscribed_to_new_followers, :boolean, default: true
  end
end
