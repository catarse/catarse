# frozen_string_literal: true

module SubscriptionPayments
  module RefundHandler
    extend ActiveSupport::Concern

    def refund
      # Reembolsa no pagarMe
      transaction = PagarMe::Transaction.find(gateway_general_data['gateway_id'])
      transaction.refund if transaction.payment_method == 'credit_card' && transaction.status == 'paid'

      remove_payment_user_balance

      add_amount_subscriber_balance if transaction.payment_method == 'boleto'

      update_payment_status
    end

    private

    def remove_payment_user_balance
      amount_to_remove = ((amount - (amount * project.service_fee)) * -1)
      add_balance_transaction(user_id: project.user_id, amount: amount_to_remove)
    end

    def add_amount_subscriber_balance
      add_balance_transaction(user_id: user.id, amount: amount)
    end

    def add_balance_transaction(user_id:, amount:)
      return if refunded?(user_id: user_id)

      BalanceTransaction.create(
        user_id: user_id,
        event_name: 'subscription_payment_refunded',
        amount: amount,
        subscription_payment_uuid: id,
        project_id: project.id
      )
    end

    def refunded?(user_id:)
      BalanceTransaction.where(event_name: 'subscription_payment_refunded',
                               subscription_payment_uuid: id, user_id: user_id
                              ).present?
    end

    def update_payment_status
      cw = CommonWrapper.new
      cw.refund_subscription_payment(self)
    end
  end
end
