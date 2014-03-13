module Contribution::PaymentEngineHandler
  extend ActiveSupport::Concern

  included do

    def payment_engine
      PaymentEngines.find_engine(self.payment_method) rescue nil
    end

    def can_do_refund?
      engine_handler { |engine| engine[:can_do_refund?] }
    end

    %i(review_path direct_refund).each do |method_name|
      define_method method_name do
        engine_handler { |engine| engine[method_name].try(:call, self) }
      end
    end

    private

    def engine_handler
      if payment_engine
        yield payment_engine
      end
    end

  end
end
