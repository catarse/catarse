module CatarsePagarme::PaymentConcern
  extend ActiveSupport::Concern

  included do
    def pagarme_delegator
      CatarsePagarme::PaymentDelegator.new(self)
    end
  end
end
