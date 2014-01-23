class PaymentNotificationObserver < ActiveRecord::Observer
  observe :payment_notification

  def before_save(payment_notification)
    return unless payment_notification.extra_data
    if payment_notification.extra_data['status_pagamento'] == '6' #payment is being processed
      Notification.notify_once(:processing_payment,
        payment_notification.contribution.user,
        {contribution_id: payment_notification.contribution.id},
        contribution: payment_notification.contribution,
        project_name: payment_notification.contribution.project.name,
        payment_method: payment_notification.contribution.payment_method)
    end
  end

end
