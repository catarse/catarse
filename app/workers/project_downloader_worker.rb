class ProjectDownloaderWorker
  include Sidekiq::Worker
  sidekiq_options retry: true

  def perform project_id
    project = Project.find project_id

    project.update_video_embed_url
    project.download_video_thumbnail
  end
end
