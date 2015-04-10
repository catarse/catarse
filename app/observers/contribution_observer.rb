class ContributionObserver < ActiveRecord::Observer
  observe :contribution

  def after_create(contribution)
    PendingContributionWorker.perform_at(2.day.from_now, contribution.id)
  end

end
