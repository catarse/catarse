# frozen_string_literal: true

class SubscriptionProjectObserver < ActiveRecord::Observer
  observe :subscription_project

  def from_draft_to_online(sub_project); 
    ProjectMetricStorageRefreshWorker.perform_in(5.seconds, sub_project.id)
  end

end
