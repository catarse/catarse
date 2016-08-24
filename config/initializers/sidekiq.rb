require 'sidekiq/api'

Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDIS_URL"] || "redis://localhost:6379/" }

  database_url = ENV['DATABASE_URL']
  if database_url
    ActiveRecord::Base.establish_connection("#{database_url}?pool=#{ENV['DB_POOL']}")
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV["REDIS_URL"] || "redis://localhost:6379/" }
end
