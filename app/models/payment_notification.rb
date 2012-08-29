class PaymentNotification < ActiveRecord::Base
  serialize :extra_data, JSON
end
