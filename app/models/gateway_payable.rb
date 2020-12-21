class GatewayPayable < ApplicationRecord
  belongs_to :payment

  validates :payment_id, presence: true
  validates :gateway_id, presence: true
  validates :transaction_id, presence: true
  validates :fee, presence: true
  validates :data, presence: true

  validates :gateway_id, uniqueness: true
end
