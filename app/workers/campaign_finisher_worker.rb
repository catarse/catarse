class CampaignFinisherWorker < ProjectBaseWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform id
    resource(id).finish
  end
end
