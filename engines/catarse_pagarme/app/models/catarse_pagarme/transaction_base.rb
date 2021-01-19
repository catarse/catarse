module CatarsePagarme
  class TransactionBase
    attr_accessor :attributes, :payment,
      :transaction, :user

    def initialize(attributes, payment)
      self.attributes = attributes
      self.payment = payment
      self.user = payment.user
    end

    def change_payment_state
      self.payment.update(attributes_to_payment)
      self.payment.save!
      delegator.update_transaction
      self.payment.payment_notifications.create(contribution_id: self.payment.contribution_id, extra_data: self.transaction.to_json)
      delegator.change_status_by_transaction(self.transaction.status)
    end

    def payment_method
      PaymentType::CREDIT_CARD
    end

    def attributes_to_payment
      {
        payment_method: payment_method,
        gateway_id: self.transaction.id,
        gateway: 'Pagarme',
        gateway_data: self.transaction.to_json,
        installments: default_installments
      }
    end

    def default_installments
      (self.transaction.installments || 1)
    end

    def delegator
      self.payment.pagarme_delegator
    end

  end
end
