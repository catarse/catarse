module Projects::Hooks
  extend ActiveSupport::Concern

  included do
    def download_video_thumbnail
      self.video_thumbnail = open(self.video.thumbnail_large)  if self.video_valid?
      self.save
    rescue OpenURI::HTTPError, TypeError => e
      Rails.logger.info "-----> #{e.inspect}"
    end

    def update_video_embed_url
      self.video_embed_url = self.video.embed_url if self.video_valid?
      self.save
    end

    def video_valid?
      self.video_url.present? && self.video
    end
  end
end
