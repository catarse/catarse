# frozen_string_literal: true

class Blog
  class << self
    def fetch_last_posts
      Rails.cache.fetch('blog_posts', expires_in: 10.minutes) do
        return [] unless CatarseSettings[:blog_url].present?
        begin
          response = Typhoeus.get("#{CatarseSettings[:blog_url]}?feed=rss2", followlocation: true, timeout: 1)
          encoded_data = response.body.force_encoding('utf-8')
          feed = Feedjira::Feed.parse encoded_data
          feed.entries
        rescue
          []
        end
      end
    end
  end
end
