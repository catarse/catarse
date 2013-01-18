class Blog
  class << self
    def fetch_last_posts
      Rails.cache.fetch('blog_posts', expires_in: 10.minutes) do
        begin
          feed = Feedzirra::Feed.fetch_and_parse("#{Configuration[:blog_url]}?feed=rss2")
          feed.entries
        rescue
          []
        end
      end
    end
  end
end
