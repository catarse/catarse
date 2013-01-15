ActionMailer::Base.default_url_options = {host: ::Configuration[:host] } if Rails.env.production?
