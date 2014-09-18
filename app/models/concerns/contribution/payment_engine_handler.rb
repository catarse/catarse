module Contribution::PaymentEngineHandler
  extend ActiveSupport::Concern

  included do

    delegate :can_do_refund?, to: :payment_engine

    def payment_engine
      PaymentEngines.find_engine(self.payment_method) || PaymentEngines::Interface.new
    end

    def review_path
      payment_engine.review_path(self)
    end

    def direct_refund
      payment_engine.direct_refund(self)
    end

    def second_slip_path
      payment_engine.try(:second_slip_path, self)
    end

    def can_generate_second_slip?
      payment_engine.try(:can_generate_second_slip?)
    end

    def update_current_billing_info
      self.address_street = user.address_street
      self.address_number = user.address_number
      self.address_neighbourhood = user.address_neighbourhood
      self.address_zip_code = user.address_zip_code
      self.address_city = user.address_city
      self.address_state = user.address_state
      self.address_phone_number = user.phone_number
      self.payer_document = user.cpf
      self.payer_name = user.display_name
    end

    def update_user_billing_info
      user.update_attributes({
        address_street: address_street.presence || user.address_street,
        address_number: address_number.presence || user.address_number,
        address_neighbourhood: address_neighbourhood.presence || user.address_neighbourhood,
        address_zip_code: address_zip_code.presence|| user.address_zip_code,
        address_city: address_city.presence || user.address_city,
        address_state: address_state.presence || user.address_state,
        phone_number: address_phone_number.presence || user.phone_number,
        cpf: payer_document.presence || user.cpf
      })
    end

  end
end
