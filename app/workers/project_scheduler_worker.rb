class ProjectSchedulerWorker
  include Sidekiq::Worker
  sidekiq_options retry: true

  def perform project_id
    resource = Project.find project_id
    Rails.logger.info "[PROJECT ONLINE #{resource.id}] #{resource.name}"
    resource.approve
  end
end
