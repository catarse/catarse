class UserTransfer < ActiveRecord::Base
  belongs_to :user

  scope :pending, -> do
   where("user_transfers.transfer_data->>'status' IN ('pending_transfer', 'processing')")
  end
end
