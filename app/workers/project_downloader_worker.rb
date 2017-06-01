# frozen_string_literal: true

class ProjectDownloaderWorker
  include Sidekiq::Worker
  sidekiq_options retry: true

  def perform(project_id)
    project = Project.find project_id
    project.download_video_thumbnail
  end
end
