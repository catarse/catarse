module Contribution::PaymentMethods
  extend ActiveSupport::Concern

  included do
    def is_credit_card?
      payment_choice.try(:downcase) == 'cartaodecredito'
    end

    def slip_payment?
      payment_choice.try(:downcase) == 'boletobancario'
    end

  end
end
