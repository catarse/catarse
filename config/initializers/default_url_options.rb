if Rails.env.production?
  ActionMailer::Base.asset_host = ::Configuration[:host]
  Rails.application.routes.default_url_options = {host: ::Configuration[:host]} 
else
  Rails.application.routes.default_url_options = {host: 'localhost:3000'} 
end
