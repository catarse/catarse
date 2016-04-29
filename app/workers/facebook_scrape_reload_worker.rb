class FacebookScrapeReloadWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(url)
    Typhoeus.post(url, params: {
      id: url,
      scrape: true,
      access_token: "#{CatarseSettings[:fb_app_id]}|#{CatarseSettings[:fb_app_secret]}"
    })
  end
end
