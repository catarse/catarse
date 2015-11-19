class UserTransfer < ActiveRecord::Base
  has_notifications
  belongs_to :user

  scope :pending, -> do
   where("user_transfers.transfer_data->>'status' IN ('pending_transfer', 'processing')")
  end

  def over_refund_limit?
    notifications.where(template_name: 'invalid_refund').count > 2
  end

end
