# frozen_string_literal: true

class BannedIp < ApplicationRecord

  validates :ip, presence: true
end
