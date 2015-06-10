class PaymentTransfer < ActiveRecord::Base
  # this user is the admin that authorized the transfer
  belongs_to :user
  belongs_to :payment
end
