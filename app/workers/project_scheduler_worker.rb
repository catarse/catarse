class ProjectSchedulerWorker < ProjectBaseWorker
  include Sidekiq::Worker
  sidekiq_options retry: true

  def perform id
    resource_action id, :push_to_online
  end
end
