module Contribution::PaymentMethods
  extend ActiveSupport::Concern

  included do
    def is_paypal?
      payment_method.try(:downcase) == 'paypal'
    end

    def is_pagarme?
      payment_method.try(:downcase) == 'pagarme'
    end

    def is_credit_card?
      payment_choice.try(:downcase) == 'cartaodecredito'
    end
  end
end
