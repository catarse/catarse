class PaymentNotification < ActiveRecord::Base
  belongs_to :contribution
end
