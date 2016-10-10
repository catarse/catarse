class DirectRefundWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, queue: 'actions'

  def perform(payment_id)
    payment = Payment.find payment_id

    begin
      payment.payment_engine.direct_refund(payment)
    rescue Exception => e
      payment.contribution.notify_to_backoffice(
        :direct_refund_worker_error,
        {
          metadata: {
            payment_id: payment.id,
            error_message: e.message,
            error_class: e.class.to_s
          }.to_json
        },
        User.find_by(email: CatarseSettings[:email_contact])
      )
    end
  end
end
