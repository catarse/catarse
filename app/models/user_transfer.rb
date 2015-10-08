class UserTransfer < ActiveRecord::Base
  belongs_to :user

  scope :pending, -> do
   where("payment_transfers.transfer_data->>'status' IN ('pending_transfer', 'processing')")
  end
end
