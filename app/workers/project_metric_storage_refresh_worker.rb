# frozen_string_literal: true

class ProjectMetricStorageRefreshWorker < ProjectBaseWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'metric_storage'

  def perform(id)
    _resource = resource(id)
    can_refresh = !%w[draft deleted].include?(_resource.state)
    can_schedule = !%w[draft rejected deleted failed successful].include?(_resource.state)

    _resource.refresh_project_metric_storage if can_refresh
    ProjectMetricStorageRefreshWorker.perform_in(10.seconds, id) if can_schedule
  end
end
