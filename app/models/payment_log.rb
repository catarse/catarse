# frozen_string_literal: true

class PaymentLog < ApplicationRecord
  validates :gateway_id, :data, presence: true
end
