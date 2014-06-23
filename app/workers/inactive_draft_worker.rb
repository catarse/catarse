class InactiveDraftWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  def perform resource_id
    resource = Project.find resource_id
    resource.notify_owner(:inactive_draft) if resource.draft?
  end
end
