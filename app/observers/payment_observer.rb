class PaymentObserver < ActiveRecord::Observer
  observe :payment

  def after_create(payment)
    PendingContributionWorker.perform_at(2.day.from_now, payment.contribution.id)
    payment.notify_to_contributor(:payment_slip) if payment.method == 'BoletoBancario'
  end

  def before_save(payment)
    notify_confirmation(payment) if payment.paid?
  end

  def from_confirmed_to_refunded_and_canceled(payment)
    do_direct_refund(payment)
  end

  def from_requested_refund_to_refunded(payment)
    payment.notify_to_contributor((payment.slip_payment? ? :refund_completed_slip : :refund_completed_credit_card))
  end
  alias :from_confirmed_to_refunded :from_requested_refund_to_refunded

  def from_pending_to_invalid_payment(payment)
    payment.notify_to_backoffice :invalid_payment
  end
  alias :from_waiting_confirmation_to_invalid_payment :from_pending_to_invalid_payment

  def from_confirmed_to_requested_refund(payment)
    payment.notify_to_backoffice :refund_request, {from_email: payment.user.email, from_name: payment.user.name}
    do_direct_refund(payment)
  end

  def from_confirmed_to_canceled(payment)
    payment.notify_to_backoffice(:payment_canceled_after_confirmed) if payment.confirmed_at.present?
    payment.notify_to_contributor((payment.slip_payment? ? :payment_canceled_slip : :payment_canceled))
  end
  alias :from_waiting_confirmation_to_canceled :from_confirmed_to_canceled
  alias :from_pending_to_canceled :from_confirmed_to_canceled

  private
  def do_direct_refund(payment)
    payment.direct_refund if payment.can_do_refund?
  rescue Exception => e
    Rails.logger.info "[REFUND ERROR] - #{e.inspect}"
    payment.invalid_refund if payment.is_pagarme?
  end

  def notify_confirmation(payment)
    contribution = payment.contribution
    contribution.notify_to_contributor(:confirm_contribution)

    if (Time.now > contribution.project.expires_at  + 7.days) && User.where(email: ::CatarseSettings[:email_payments]).present?
      contribution.notify_to_backoffice(:payment_confirmed_after_project_was_closed)
    end
  end
end
