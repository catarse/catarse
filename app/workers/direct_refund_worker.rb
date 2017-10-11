# frozen_string_literal: true

class DirectRefundWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, queue: 'actions'

  def perform(payment_id)
    payment = Payment.find payment_id

    begin
      if payment.slip_payment? && payment.paid?
        Payment.transaction do
          BalanceTransaction.insert_contribution_refund(payment.contribution_id)
          unless payment.refunded?
            payment.contribution.notify_to_contributor(:contribution_refunded)
            [15, 30, 60, 90].each do |day|
              payment.contribution.notify(:contribution_refunded, payment.contribution.user, payment.contribution, {deliver_at: Time.now + day.days})
            end
          end
          payment.refund
        end
      else
        payment.payment_engine.direct_refund(payment)
      end
    rescue Exception => e
      Raven.capture_exception(e)
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
