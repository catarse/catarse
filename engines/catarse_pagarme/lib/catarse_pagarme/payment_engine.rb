# frozen_string_literal: true

module CatarsePagarme
  class PaymentEngine
    def name
      'Pagarme'
    end

    def review_path contribution
    end

    def locale
      'pt'
    end

    def can_do_refund?
      true
    end

    def direct_refund contribution
      contribution.pagarme_delegator.refund
    end

    def transfer contribution
      contribution.pagarme_delegator.transfer_funds
    end

    def can_generate_second_slip?
      true
    end

    def second_slip_path(payment)
      # The second slip generates a new payment base on the contribution ID
      url_helpers.second_slip_pagarme_path(id: payment.contribution.id)
    end

    protected

    def url_helpers
      CatarsePagarme::Engine.routes.url_helpers
    end
  end
end

