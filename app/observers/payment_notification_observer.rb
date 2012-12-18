class PaymentNotificationObserver < ActiveRecord::Observer
  observe :payment_notification

  def before_save(payment_notification)
    return unless payment_notification.extra_data
    if payment_notification.extra_data['status_pagamento'] == '6' #payment is being processed
      Notification.create_notification_once(:processing_payment,
        payment_notification.backer.user,
        {backer_id: payment_notification.backer.id},
        backer: payment_notification.backer,
        project_name: payment_notification.backer.project.name,
        payment_method: payment_notification.backer.payment_method)
    end
  end

end
