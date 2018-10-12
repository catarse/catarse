# frozen_string_literal: true

class PaymentObserver < ActiveRecord::Observer
  observe :payment

  def after_save(payment)
    contribution = payment.contribution
    contribution.notify_to_contributor(:payment_slip) if payment.slip_payment? && payment.gateway_data
  end

  def from_pending_to_paid(payment)
    notify_confirmation(payment)

    payment.direct_refund if %w(rejected failed).include?(payment.project.state)
  end
  alias from_refused_to_paid from_pending_to_paid

  def from_paid_to_chargeback(payment)
    payment.notify_to_backoffice(:admin_chargeback, {
                                   from_email: payment.user.email,
                                   from_name: payment.user.display_name
                                 })
    payment.contribution.notify_once(
      :project_owner_chargeback,
      payment.project.user,
      payment.contribution,
      {}
    ) unless %w(failed draft rejected).include?(payment.project.state)
    BalanceTransaction.insert_contribution_chargeback(payment.id)
  end
  alias from_refunded_to_chargeback from_paid_to_chargeback
  alias from_pending_to_chargeback from_paid_to_chargeback
  alias from_pending_refund_to_chargeback from_paid_to_chargeback

  def from_chargeback_to_paid(payment)
    payment.notify_to_backoffice(:chargeback_reverse, {
                                   from_email: payment.user.email,
                                   from_name: payment.user.display_name
                                 })
  end

  def from_pending_refund_to_refunded(payment)
    return if payment.is_donation?
    return if payment.contribution.balance_refunded?
    payment.contribution.notify_to_contributor(:refund_completed_credit_card) if payment.is_credit_card?
  end
  alias from_paid_to_refunded from_pending_refund_to_refunded
  alias from_deleted_to_refunded from_pending_refund_to_refunded

  #def from_pending_refund_to_paid(payment)
  #  payment.invalid_refund
  #end
  #alias from_refunded_to_paid from_pending_refund_to_paid

  def from_pending_to_invalid_payment(payment)
    payment.notify_to_backoffice :invalid_payment
  end
  alias from_waiting_confirmation_to_invalid_payment from_pending_to_invalid_payment

  #def from_paid_to_pending_refund(payment)
  #  if payment.slip_payment?
  #    payment.contribution.notify_to_contributor(:contributions_project_unsuccessful_slip)
  #  end
  #end

  def from_paid_to_refused(payment)
    contribution = payment.contribution
    contribution.notify_to_contributor(:contribution_canceled) unless payment.slip_payment?
  end
  alias from_pending_to_refused from_paid_to_refused

  private

  def notify_confirmation(payment)
    contribution = payment.contribution
    project = contribution.project
    project.reload

    unless payment.paid_at.present?
      contribution.notify_to_contributor(:confirm_contribution)

      if project.successful? && project.successful_pledged_transaction
        transfer_diff = (
          project.paid_pledged - project.all_pledged_kind_transactions.sum(:amount))

        if transfer_diff >= contribution.value
          BalanceTransaction.insert_contribution_confirmed_after_project_finished(
            project.id, contribution.id
          )
          contribution.notify(
            :project_contribution_confirmed_after_finished,
            project.user,
            contribution)
        end
      end
    end
  end
end
