class PaymentNotification < ActiveRecord::Base
  belongs_to :contribution
  serialize :extra_data, JSON

  # This methods should be called by payments engines
  def deliver_process_notification
    deliver_contributor_notification(:processing_payment)
  end

  def deliver_slip_canceled_notification
    deliver_contributor_notification(:contribution_canceled_slip)
  end

  private

  def deliver_contributor_notification(template_name)
    self.contribution.notify_to_contributor(template_name)
  end

end
