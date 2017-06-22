# frozen_string_literal: true

class GatewayBalanceOperation < ActiveRecord::Base
  serialize :operation_data, JSON
end
