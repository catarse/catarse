# frozen_string_literal: true

class GatewayBalanceOperation < ApplicationRecord
  serialize :operation_data, JSON
end
