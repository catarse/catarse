class TransferWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  def perform(payment_id)
    payment = Payment.find payment_id
    payment_engine = PaymentEngines.find_engine('Pagarme')
    payment_engine.transfer(payment)
  end
end
