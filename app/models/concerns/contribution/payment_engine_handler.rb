module Contribution::PaymentEngineHandler
  extend ActiveSupport::Concern

  included do

    def payment_engine
      PaymentEngines.find_engine(self.payment_method) rescue nil
    end

    [:review_path, :refund_path].each do |method_name|
      define_method method_name do
        if payment_engine
          payment_engine[method_name].try(:call, self)
        end
      end
    end

  end
end
