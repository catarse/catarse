class Donation < ActiveRecord::Base
  has_notifications
  has_many :contributions
end
