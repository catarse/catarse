class DirectRefundWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5, queue: 'actions'

  def perform(payment_id)
    payment = Payment.find payment_id
    payment.payment_engine.direct_refund(payment)
  end
end

