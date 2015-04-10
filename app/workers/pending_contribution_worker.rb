class PendingContributionWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  def perform resource_id
    resource = Contribution.find resource_id

    if ( resource.payments.empty? || resource.pending? ) && resource.user.has_no_confirmed_contribution_to_project(resource.project_id)
      resource.notify_to_contributor(:pending_payment)
    end
  end
end
