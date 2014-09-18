# Be sure to restart your server when you modify this file.

if Rails.env.production? && CatarseSettings.get_without_cache(:base_domain)
  Catarse::Application.config.session_store :cookie_store, key: CatarseSettings.get_without_cache(:secret_token), domain: CatarseSettings.get_without_cache(:base_domain)
else
  Catarse::Application.config.session_store :cookie_store, key: CatarseSettings.get_without_cache(:secret_token)
end

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# Catarse::Application.config.session_store :active_record_store

