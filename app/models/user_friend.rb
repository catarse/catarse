class UserFriend < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, class_name: 'User', foreign_key: :friend_id
  validates :user_id, :friend_id, presence: true
  validates :friend_id, uniqueness: { scope: :user_id }
end
