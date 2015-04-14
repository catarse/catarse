module Payment::PaymentEngineHandler
  extend ActiveSupport::Concern

  included do

    delegate :can_do_refund?, to: :payment_engine

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
