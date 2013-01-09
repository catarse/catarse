if Rails.env.production?
  ActionMailer::Base.default_url_options = {host: ::Configuration[:host] }
end
