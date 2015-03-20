module Shared::VideoHandler
  extend ActiveSupport::Concern

  included do
    validates_format_of :video_url, with: /(https?\:\/\/|)(youtu(\.be|be\.com)|vimeo).*+/, message: I18n.t('project.video_regex_validation'), allow_blank: true

    def video
      @video ||= VideoInfo.get(self.video_url) if self.video_url.present?
    end

    def video_valid?
      self.video_url.present? && self.video
    end

    def display_video_embed_url
      if self.video_embed_url
        "#{self.video_embed_url}?title=0&byline=0&portrait=0&autoplay=0"
      end
    end

    def update_video_embed_url
      self.video_embed_url = self.video.embed_url if self.video_valid?
      self.save(validate: false)
    end
  end

end
