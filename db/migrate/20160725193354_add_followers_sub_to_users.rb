class AddFollowersSubToUsers < ActiveRecord::Migration
  def change
    add_column :users, :subscribed_to_new_followers, :boolean, default: true
  end
end
