# frozen_string_literal: true

class ProjectMetricStorageRefreshWorker < ProjectBaseWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'metric_storage'

  def perform(id)
    _resource = resource(id)
    can_refresh = !%w[draft deleted].include?(_resource.state)

    _resource.refresh_project_metric_storage if can_refresh
  end
end
