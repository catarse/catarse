# frozen_string_literal: true

class ProjectScoreStorageRefreshWorker < ProjectBaseWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, queue: 'default'

  def perform(id)
    resource(id).refresh_project_score_storage
  end
end
