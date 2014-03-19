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
  end
end
