# frozen_string_literal: true

class CreditCard < ActiveRecord::Base
  belongs_to :user
end
