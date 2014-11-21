Rake::Task["db:structure:dump"].clear if Rails.env.production?

Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDISCLOUD_URL"] || "redis://localhost:6379/" }
end
 
Sidekiq.configure_client do |config|
  config.redis = { url: ENV["REDISCLOUD_URL"] || "redis://localhost:6379/" }
end

Catarse::Application.configure do
  config.session_store :cookie_store, key: CatarseSettings.get_without_cache(:secret_token)
  config.i18n.load_path += Dir[Rails.root.join('lib', 'fundoo', 'locales', '*.{rb,yml}').to_s]
  config.i18n.default_locale = :en
  config.paths["app/views"].unshift("#{Rails.root}/lib/fundoo/views/")
  
end