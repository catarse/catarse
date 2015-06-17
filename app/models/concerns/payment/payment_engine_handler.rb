module Payment::PaymentEngineHandler
  extend ActiveSupport::Concern

  included do

    delegate :can_do_refund?, to: :payment_engine

    def is_paypal?
      gateway.downcase == 'paypal'
    end

    def is_pagarme?
      gateway.downcase == 'pagarme'
    end

    # Get the current status from payment direct on gateway
    def current_transaction_state
      payment_delegator.try(:transaction).try(:status)
    end

    # Change current payment status using the gateway payment current status
    def change_status_from_transaction
      payment_delegator.try(:change_status_by_transaction, current_transaction_state)
    end

    # References to current payment engine delegator
    def payment_delegator
      self.try(:pagarme_delegator)
    end

    def payment_engine
      PaymentEngines.find_engine(self.gateway) || PaymentEngines::Interface.new
    end

    def review_path
      payment_engine.review_path(self)
    end

    def direct_refund
      payment_engine.direct_refund(self)
    end

    def second_slip_path
      payment_engine.second_slip_path(self) if payment_engine.try(:can_generate_second_slip?)
    end

    def can_generate_second_slip?
      payment_engine.try(:can_generate_second_slip?)
    end
  end
end
