if Rails.env.production?
  ActionMailer::Base.asset_host = ::CatarseSettings[:host]
  Rails.application.routes.default_url_options = {host: ::CatarseSettings[:host]} 
else
  Rails.application.routes.default_url_options = {host: 'localhost:3000'} 
end
