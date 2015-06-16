class PaymentTransfer < ActiveRecord::Base
  # this user is the admin that authorized the transfer
  belongs_to :user
  belongs_to :payment

  # retun the transfers that are pending to transfer by pagar.me
  scope :pendings, -> do
    where("payment_transfers.transfer_data->>'status' = 'pending_transfer'")
  end
end
