# frozen_string_literal: true

class Donation < ActiveRecord::Base
  has_notifications
  has_many :contributions
  belongs_to :user
end
