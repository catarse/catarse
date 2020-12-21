class AddSubscribedToFriendsContributionsToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :subscribed_to_friends_contributions, :boolean, default: true
  end
end
