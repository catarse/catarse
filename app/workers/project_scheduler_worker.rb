class ProjectSchedulerWorker < ProjectBaseWorker
  include Sidekiq::Worker
  sidekiq_options retry: true

  def perform id
    resource(id).push_to_online
  end
end
