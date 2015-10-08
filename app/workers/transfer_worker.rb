class TransferWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  def perform(payment_id)
    payment = Payment.find payment_id
    payment.payment_engine.transfer(payment)
  end
end
