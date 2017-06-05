# frozen_string_literal: true

class GatewayPayment < ActiveRecord::Base
  belongs_to :payment
end
