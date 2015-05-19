class PaymentLog < ActiveRecord::Base
  validates :gateway_id, :data, presence: true
end
