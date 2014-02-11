class PendingContributionWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  def perform resource_id
    resource = Contribution.find resource_id

    if resource.pending?
      Notification.notify_once(:pending_payment,
        resource.user,
        { contribution_id: resource.id },
        contribution: resource
      )
    end
  end
end
