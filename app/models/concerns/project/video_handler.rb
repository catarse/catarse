# frozen_string_literal: true

module Project::VideoHandler
  extend ActiveSupport::Concern
  include Shared::VideoHandler

  included do
    mount_uploader :video_thumbnail, ProjectUploader

    def download_video_thumbnail
      self.video_thumbnail = open(video.thumbnail_large) if video_valid?
      save
    rescue OpenURI::HTTPError, TypeError => e
      Rails.logger.info "-----> #{e.inspect}"
    end
  end
end
