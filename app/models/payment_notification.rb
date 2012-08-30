class PaymentNotification < ActiveRecord::Base
  belongs_to :backer
  serialize :extra_data, JSON
end
