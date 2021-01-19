module CatarsePagarme
  class Engine < ::Rails::Engine
    isolate_namespace CatarsePagarme

    config.to_prepare do
      ::Payment.send(:include, CatarsePagarme::PaymentConcern)
      ::BalanceTransfer.send(:include, CatarsePagarme::BalanceTransferConcern)
    end
  end
end
