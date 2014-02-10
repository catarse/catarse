class PaymentNotification < ActiveRecord::Base
  schema_associations
  serialize :extra_data, JSON

  # This method should be called by payments engines
  # when user payment status is processing
  def deliver_process_notification
    Notification.notify_once(:processing_payment,
      self.contribution.user,
      { contribution_id: self.contribution.id },
      contribution: self.contribution
    )
  end
end
