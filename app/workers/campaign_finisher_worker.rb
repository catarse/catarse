class CampaignFinisherWorker < ProjectBaseWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform id
    resource_action id, :finish
  end
end
