if Rails.env == "production"
  BASE_URL = "http://catarse.me"
else
  BASE_URL = "http://localhost:3000"
end
