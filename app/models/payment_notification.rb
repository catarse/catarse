class PaymentNotification < ActiveRecord::Base
  schema_associations
  serialize :extra_data, JSON

  # This methods should be called by payments engines
  def deliver_process_notification
    deliver_contributor_notification(:processing_payment)
  end

  def deliver_slip_canceled_notification
    deliver_contributor_notification(:slip_payment_canceled)
  end

  private

  def deliver_contributor_notification(template_name)
    Notification.notify_once(template_name,
      self.contribution.user,
      { contribution_id: self.contribution.id },
      contribution: self.contribution
    )
  end

end
