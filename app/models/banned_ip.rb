# frozen_string_literal: true

class BannedIp < ActiveRecord::Base

  validates :ip, presence: true
end
