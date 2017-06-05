# frozen_string_literal: true

class LoginActivity < ActiveRecord::Base
  belongs_to :user
end
