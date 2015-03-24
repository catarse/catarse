if Rails.env.production?
  ActionMailer::Base.asset_host = ::CatarseSettings.get_without_cache(:base_url)
  Rails.application.routes.default_url_options = {host: ::CatarseSettings.get_without_cache(:host), protocol: 'https'} 
else
  Rails.application.routes.default_url_options = {host: 'localhost:3000'} 
end
