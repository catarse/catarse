class PaymentNotification < ActiveRecord::Base
  serialize :extra_data
end
