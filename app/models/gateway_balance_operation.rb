class GatewayBalanceOperation < ActiveRecord::Base
  serialize :operation_data, JSON
end
