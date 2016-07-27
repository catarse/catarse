class UserFollow < ActiveRecord::Base
  has_notifications
  belongs_to :user
  belongs_to :follow, class_name: 'User', foreign_key: :follow_id
  scope :since_last_day, -> { where(created_at: Time.current - 1.day .. Time.current) }

end
