if Rails.env.production?
  Rails.application.routes.default_url_options = {host: ::Configuration[:host]} 
else
  Rails.application.routes.default_url_options = {host: 'localhost:3000'} 
end
