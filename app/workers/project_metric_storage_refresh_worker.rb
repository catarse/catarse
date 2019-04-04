# frozen_string_literal: true

class ProjectMetricStorageRefreshWorker < ProjectBaseWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'metric_storage'

  def perform(id)
    _resource = resource(id)
    unless ['draft', 'rejected'].include?(_resource.state)
      _resource.refresh_project_metric_storage
    end
    ProjectMetricStorageRefreshWorker.perform_in(10.seconds, id)
  end
end
