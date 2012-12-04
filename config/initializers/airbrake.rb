Airbrake.configure do |config|
  config.api_key = Configuration[:airbrake_key] if Configuration[:airbrake_key].present?
  config.host    = Configuration[:airbrake_host] if Configuration[:airbrake_host].present?
end
