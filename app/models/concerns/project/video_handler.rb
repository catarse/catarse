module Project::VideoHandler
  extend ActiveSupport::Concern
  include Shared::VideoHandler

  included do
    mount_uploader :video_thumbnail, ProjectUploader

    def download_video_thumbnail
      self.video_thumbnail = open(self.video.thumbnail_large)  if self.video_valid?
      self.save
    rescue OpenURI::HTTPError, TypeError => e
      Rails.logger.info "-----> #{e.inspect}"
    end
  end
end
