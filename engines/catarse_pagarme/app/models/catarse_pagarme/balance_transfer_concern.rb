# frozen_string_literal: true

module CatarsePagarme::BalanceTransferConcern
  extend ActiveSupport::Concern

  included do
    def pagarme_delegator
      CatarsePagarme::BalanceTransferDelegator.new(self)
    end
  end
end
