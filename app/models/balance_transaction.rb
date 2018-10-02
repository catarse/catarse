# frozen_string_literal: true

class BalanceTransaction < ActiveRecord::Base
  EVENT_NAMES = %w[
    catarse_contribution_fee
    project_contribution_confirmed_after_finished
    balance_transfer_project
    balance_transfer_request
    balance_transfer_error
    successful_project_pledged
    catarse_project_service_fee
    contribution_refund
    refund_contributions
    subscription_fee
    irrf_tax_project
    subscription_payment
    contribution_chargedback
    subscription_payment_chargedback
    balance_expired
    contribution_refunded_after_successful_pledged
    subscription_payment_refunded
    balance_transferred_to
    balance_received_from
  ].freeze

  belongs_to :project
  belongs_to :contribution
  belongs_to :user
  belongs_to :subscription_payment
  belongs_to :from_user, class_name: 'User'
  belongs_to :to_user, class_name: 'User'

  validates :event_name, inclusion: { in: EVENT_NAMES }
  validates :amount, :event_name, :user_id, presence: true

  after_create :refresh_metadata

  def refresh_metadata
    ::BalanceTransaction.refresh_metadata(self)
  end

  ## CLASS METHODS
  def self.refresh_metadata(balance_transaction)
    metadata = {
      amount: balance_transaction.amount,
      event_name: balance_transaction.event_name,
      origin_objects: {
        from_user_name: balance_transaction.from_user.try(:display_name),
        to_user_name: balance_transaction.to_user.try(:display_name),
        service_fee: balance_transaction.project.try(:service_fee),
        contributor_name: balance_transaction.contribution.try(:user).try(:display_name),
        subscriber_name: balance_transaction.subscription_payment.try(:user).try(:display_name),
        subscription_reward_label: balance_transaction.subscription_payment.try(:reward).try(:display_label),
        id: (balance_transaction.project_id.presence || balance_transaction.contribution_id),
        project_id: balance_transaction.project_id,
        contribution_id: balance_transaction.contribution_id,
        project_name: balance_transaction.project.try(:name)
      }
    }
    balance_transaction.update_column(:metadata, metadata)
  rescue StandardError => e
    Raven.extra_context(balance_transaction_id: balance_transaction.try(:id))
    Raven.capture_exception(e)
    Raven.extra_context({})
  end

  def self.insert_balance_transfer_between_users(from_user, to_user)
    from_user.reload
    return if from_user.total_balance <= 0

    transaction do
      create!(
        user_id: from_user.id,
        from_user_id: from_user.id,
        to_user_id: to_user.id,
        amount: from_user.total_balance*-1,
        event_name: 'balance_transferred_to'
      )
      create!(
        user_id: to_user.id,
        from_user_id: from_user.id,
        to_user_id: to_user.id,
        amount: from_user.total_balance,
        event_name: 'balance_received_from'
      )
    end
  end

  def self.insert_balance_expired(balance_transaction_id)
		transaction = self.find balance_transaction_id
		return unless transaction.can_expire_on_balance?

    create!(
      user_id: transaction.user_id,
      event_name: 'balance_expired',
      amount: (transaction.amount * -1),
      contribution_id: transaction.contribution_id,
      project_id: transaction.project_id
    )
  end

  def self.insert_contribution_chargeback(payment_id)
    payment = Payment.find payment_id
    contribution = payment.contribution
    project = contribution.project

    return unless payment.chargeback?
    return if contribution.chargedback_on_balance?
    return unless project.successful_pledged_transaction.present?

    create!(
      user_id: contribution.project.user_id,
      event_name: 'contribution_chargedback',
      amount: ((contribution.value - (contribution.value * contribution.project.service_fee)) * -1),
      contribution_id: contribution.id,
      project_id: contribution.project_id
    )
  end

  def self.insert_subscription_payment_chargedback(payment_id)
    payment = SubscriptionPayment.find payment_id

    return unless payment.chargeback?
    return if payment.chargedback_on_balance?

    create!(
      user_id: contribution.project.user_id,
      event_name: 'subscription_payment_chargedback',
      amount: ((payment.amount - (payment.amount * payment.project.service_fee)) * -1),
      subscription_payment_uuid: payment.id,
      project_id: payment.project.id
    )
  end

  def self.insert_subscription_payment(subscription_payment_id)
    subscription_payment = SubscriptionPayment.find subscription_payment_id
    subscription = subscription_payment.subscription
    return if subscription_payment.status != 'paid'
    return if subscription_payment.already_in_balance?

    transaction do
      default_params = {
        user_id: subscription.project.user_id,
        project_id: subscription.project.id,
        subscription_payment_uuid: subscription_payment.id,
      }

      create!(default_params.merge(
        event_name: 'subscription_payment',
        amount: (subscription_payment.data['amount'].to_f / 100.0)
      ))

      create!(default_params.merge(
        event_name: 'subscription_fee',
        amount: ((subscription_payment.data['amount'].to_f / 100.0) * subscription.project.service_fee) * -1
      ))
    end
  end

  def self.insert_project_refund_contributions(project_id)
    project = Project.find project_id
    return unless project.all_pledged_kind_transactions.present?
    return if project.balance_transactions.where(event_name: 'refund_contributions').exists?

    transaction do
      default_params = {
        project_id: project_id, user_id: project.user_id }

      create!(default_params.merge(
        event_name: 'refund_contributions',
        amount: -(project.total_amount_tax_included)
      ))
    end
  end

  def self.insert_contribution_refund(contribution_id)
    contribution = Contribution.find contribution_id
    project = contribution.project
    return unless contribution.confirmed?
    return if contribution.balance_refunded?

    create!(
      user_id: contribution.user_id,
      event_name: 'contribution_refund',
      amount: contribution.value,
      contribution_id: contribution.id,
      project_id: contribution.project_id
    )
  end

  def self.insert_contribution_refunded_after_successful_pledged(contribution_id)
    contribution = Contribution.find contribution_id
    project = contribution.project
    return unless contribution.confirmed?
    return if project.project_cancelation.present?

    if project.successful? && project.successful_pledged_transaction.present?
      transaction do
        contribution.notify_once(
          :project_contribution_refunded_after_successful_pledged,
          project.user,
          contribution
        )
        create!(
          user_id: project.user_id,
          event_name: 'contribution_refunded_after_successful_pledged',
          amount: (contribution.value-(contribution.value*project.service_fee))*-1,
          contribution_id: contribution.id,
          project_id: project.id
        )
      end
    end
  end

  def self.insert_contribution_confirmed_after_project_finished(project_id, contribution_id)
    project = Project.find project_id
    contribution = Contribution.find contribution_id
    return unless project.successful?
    return unless contribution.confirmed?

    transaction do
      default_params = {
        contribution_id: contribution_id,
        project_id: project_id,
        user_id: project.user_id
      }

      create!(default_params.merge(
                event_name: 'project_contribution_confirmed_after_finished',
                amount: contribution.value
      ))
      create!(default_params.merge(
                event_name: 'catarse_contribution_fee',
                amount: (contribution.value * contribution.project.service_fee) * -1
      ))
    end
  end

  def self.insert_successful_project_transactions(project_id)
    project = Project.find project_id
    return unless project.successful?
    return unless project.project_total.present?
    transaction do
      default_params = { project_id: project_id, user_id: project.user_id }

      create!(default_params.merge(
        event_name: 'successful_project_pledged',
        amount: project.paid_pledged
      ))
      create!(default_params.merge(
        event_name: 'catarse_project_service_fee',
        amount: (project.total_catarse_fee * -1)
      ))

      # uncomment to use irrf tax
      # if project.irrf_tax > 0
      #   create!(default_params.merge(
      #     event_name: 'irrf_tax_project',
      #     amount: project.irrf_tax
      #   ))
      # end
    end
  end


  ## INSTANCE METHODS

  def can_expire_on_balance?
		pluck_from_database("can_expire_on_balance")
  end

  private

  def pluck_from_database(field)
		BalanceTransaction.where(id: id).pluck("balance_transactions.#{field}").first
  end
end
