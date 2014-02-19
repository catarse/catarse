class PaymentNotification < ActiveRecord::Base
  schema_associations
  serialize :extra_data, JSON

  # This methods should be called by payments engines
  def deliver_process_notification
    Notification.notify_once(:processing_payment,
      self.contribution.user,
      { contribution_id: self.contribution.id },
      contribution: self.contribution
    )
  end

  def deliver_slip_canceled_notification
    Notification.notify_once(:slip_payment_canceled,
      self.contribution.user,
      { contribution_id: self.contribution.id },
      contribution: self.contribution
    )
  end

end
