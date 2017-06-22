# frozen_string_literal: true

class SocialFollower < ActiveRecord::Base
  belongs_to :user, class_name: 'User', foreign_key: :user_id
  validates :user_id, presence: true
  validates :username, presence: true
  validates :profile_type, presence: true
  validates :followers, numericality: { only_integer: true, greater_than: 0 }
end
