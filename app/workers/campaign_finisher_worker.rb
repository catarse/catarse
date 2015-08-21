class CampaignFinisherWorker < ProjectBaseWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform id
    resource(id).payments.where('gateway_id IS NOT NULL').with_states(%w(paid pending pending_refund)).each do |payment|
      payment.pagarme_delegator.update_transaction
      payment.change_status_from_transaction
    end

    resource(id).finish
  end
end
