class UserFollow < ActiveRecord::Base
  belongs_to :user
  belongs_to :follow, class_name: 'User', foreign_key: :follow_id
end
