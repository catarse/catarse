class PaymentObserver < ActiveRecord::Observer
  observe :payment

  def after_create(payment)
    contribution = payment.contribution
    contribution.notify_to_contributor(:payment_slip) if payment.slip_payment?
  end

  def from_pending_to_paid(payment)
    notify_confirmation(payment)
  end

  def from_pending_refund_to_refunded(payment)
    payment.contribution.notify_to_contributor((payment.slip_payment? ? :refund_completed_slip : :refund_completed_credit_card))
  end
  alias :from_paid_to_refunded :from_pending_refund_to_refunded
  alias :from_deleted_to_refunded :from_pending_refund_to_refunded

  def from_pending_refund_to_paid(payment)
    payment.invalid_refund
  end
  alias :from_refunded_to_paid :from_pending_refund_to_paid

  def from_pending_to_invalid_payment(payment)
    payment.notify_to_backoffice :invalid_payment
  end
  alias :from_waiting_confirmation_to_invalid_payment :from_pending_to_invalid_payment

  def from_paid_to_pending_refund(payment)
    if payment.slip_payment?
      payment.contribution.notify(
        :contributions_project_unsucessful_slip,
        payment.user, payment.contribution)
    end
  end

  def from_paid_to_refused(payment)
    contribution = payment.contribution
    contribution.notify_to_backoffice(:contribution_canceled_after_confirmed,
                                      { from_email: contribution.user.email, from_name: contribution.user.name })
    contribution.notify_to_contributor((payment.slip_payment? ? :contribution_canceled_slip : :contribution_canceled))
  end
  alias :from_pending_to_refused :from_paid_to_refused

  private
  def notify_confirmation(payment)
    contribution = payment.contribution
    contribution.notify_to_contributor(:confirm_contribution)

    if (Time.current > contribution.project.expires_at  + 7.days) && User.where(email: ::CatarseSettings[:email_payments]).present?
      contribution.notify_to_backoffice(:payment_confirmed_after_project_was_closed)
    end
  end
end
