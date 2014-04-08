class PendingContributionWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  def perform resource_id
    resource = Contribution.find resource_id
    resource.notify_to_contributor(:pending_payment) if resource.pending? && resource.user.contributions.where(project_id: resource.project_id).with_states(['confirmed','waiting_confirmation']).empty?
  end
end
