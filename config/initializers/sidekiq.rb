require 'sidekiq/api'

Sidekiq.configure_server do |config|
  config.redis = { url: "redis://#{ENV["REDIS_PORT_6379_TCP_ADDR"]}:#{ENV['REDIS_PORT_6379_TCP_PORT']}" || "redis://localhost:6379/" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://#{ENV["REDIS_PORT_6379_TCP_ADDR"]}:#{ENV['REDIS_PORT_6379_TCP_PORT']}" || "redis://localhost:6379/" }
end
