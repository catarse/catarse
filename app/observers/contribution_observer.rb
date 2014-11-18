class ContributionObserver < ActiveRecord::Observer
  observe :contribution

  def after_create(contribution)
    contribution.define_key
    PendingContributionWorker.perform_at(2.day.from_now, contribution.id)
  end

  def after_save(contribution)
    if contribution.payment_choice_was.nil? && contribution.payment_choice == 'BoletoBancario'
      contribution.notify_to_contributor(:payment_slip)
    end
  end

  def before_save(contribution)
    notify_confirmation(contribution) if contribution.confirmed? && contribution.confirmed_at.nil?
  end

  def from_confirmed_to_refunded_and_canceled(contribution)
    do_direct_refund(contribution)
  end

  def from_requested_refund_to_refunded(contribution)
    contribution.notify_to_contributor((contribution.slip_payment? ? :refund_completed_slip : :refund_completed_credit_card))
  end
  alias :from_confirmed_to_refunded :from_requested_refund_to_refunded

  def from_pending_to_invalid_payment(contribution)
    contribution.notify_to_backoffice :invalid_payment
  end
  alias :from_waiting_confirmation_to_invalid_payment :from_pending_to_invalid_payment

  def from_confirmed_to_requested_refund(contribution)
    contribution.notify_to_backoffice :refund_request, {from_email: contribution.user.email, from_name: contribution.user.name}
    do_direct_refund(contribution)
  end

  def from_confirmed_to_canceled(contribution)
    contribution.notify_to_backoffice(:contribution_canceled_after_confirmed) if contribution.confirmed_at.present?
    contribution.notify_to_contributor((contribution.slip_payment? ? :contribution_canceled_slip : :contribution_canceled))
  end
  alias :from_waiting_confirmation_to_canceled :from_confirmed_to_canceled
  alias :from_pending_to_canceled :from_confirmed_to_canceled

  private
  def do_direct_refund(contribution)
    contribution.direct_refund if contribution.can_do_refund?
  rescue Exception => e
    Rails.logger.info "[REFUND ERROR] - #{e.inspect}"
    contribution.invalid_refund if contribution.is_pagarme?
  end

  def notify_confirmation(contribution)
    contribution.confirmed_at = Time.now
    contribution.notify_to_contributor(:confirm_contribution)

    if (Time.now > contribution.project.expires_at  + 7.days) && User.where(email: ::CatarseSettings[:email_payments]).present?
      contribution.notify_to_backoffice(:contribution_confirmed_after_project_was_closed)
    end
  end
end
