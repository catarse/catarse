class UserFriend < ActiveRecord::Base
  validates :user_id, :friend_id, presence: true
  validates :friend_id, uniqueness: { scope: :user_id }
end
