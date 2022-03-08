# frozen_string_literal: true

class ProjectMetricStorageRefreshWorker < ProjectBaseWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'metric_storage'

  def perform(id)
    _resource = resource(id)

    _resource.refresh_project_metric_storage if can_refresh?(_resource)
  end

  private

  def not_comming_soon_landing_page?(project)
    project.state != 'draft' ||
      (project.state == 'draft' && project.has_comming_soon_landing_page_integration?)
  end

  def not_in_deleted?(project)
    project.state != 'deleted'
  end

  def can_refresh?(project)
    not_in_deleted?(project) && not_comming_soon_landing_page?(project)
  end
end
