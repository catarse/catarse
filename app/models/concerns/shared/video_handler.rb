# frozen_string_literal: true

module Shared::VideoHandler
  extend ActiveSupport::Concern

  included do
    validates_format_of :video_url, with: /(https?\:\/\/|)(youtu(\.be|be\.com)|vimeo).*+/, message: I18n.t('project.video_regex_validation'), allow_blank: true

    def video
      if video_url.present?
        @video ||= begin
                     VideoInfo.get(video_url)
                   rescue
                     nil
                   end
      end
    end

    def video_valid?
      video_url.present? && video
    end

    def display_video_embed_url
      if video_embed_url
        "#{video_embed_url}?title=0&byline=0&portrait=0&autoplay=0"
      end
    end
  end
end
