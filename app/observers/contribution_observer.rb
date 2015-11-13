class ContributionObserver < ActiveRecord::Observer
  observe :contribution

  def after_create(contribution)
    project = contribution.project
    if project.expires_at.nil? || project.expires_at - Time.now > 2.days
      PendingContributionWorker.perform_at(2.day.from_now, contribution.id)
    end
  end

end
