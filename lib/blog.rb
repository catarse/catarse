class Blog
  class << self
    def fetch_last_posts
      Rails.cache.fetch('blog_posts', expires_in: 10.minutes) do
        feed = Feedzirra::Feed.fetch_and_parse("#{I18n.t('site.blog')}?feed=rss2")
        feed.entries
      end
    end
  end
end
