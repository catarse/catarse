class CampaignFinisherWorker < ProjectBaseWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, queue: 'finisher'

  def perform id
    resource(id).payments.where('gateway_id IS NOT NULL').with_states(%w(paid pending pending_refund)).find_each(batch_size: 100) do |payment|
      payment.pagarme_delegator.update_transaction
      payment.change_status_from_transaction
    end

    resource(id).finish
  end
end
