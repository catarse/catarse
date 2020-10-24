# frozen_string_literal: true

class PaymentTransfer < ApplicationRecord
  # this user is the admin that authorized the transfer
  belongs_to :user
  belongs_to :payment

  # retun the transfers that are pending to transfer by pagar.me
  scope :pending, -> do
    where("payment_transfers.transfer_data->>'status' IN ('pending_transfer', 'processing')")
  end
end
