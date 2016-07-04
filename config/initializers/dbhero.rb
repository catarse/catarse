Dbhero.configure do |config|
  config.max_rows_limit = 20_000
  # Use authentication on private pages
  # if you are using devise you can keep the "authenticate_user!"
  config.authenticate = true

  # Method to get the current user authenticated on your app
  # if you are using devise you can keep the "current_user"
  config.current_user_method = :current_user

  # uncomment to use custom user auth
  config.custom_user_auth_condition = lambda do |user|
    user.admin?
  end

  # String representation for user
  # when creating a dataclip just save on user field
  config.user_representation = :email

  # Google drive integration, uncomment to use ;)
  # you can get you google api credentials here:
  # https://developers.google.com/drive/web/auth/web-server
  config.google_api_id = CatarseSettings.get_without_cache(:google_api_id)
  config.google_api_secret = CatarseSettings.get_without_cache(:google_api_secret)

  config.cached_query_exp = 5.minutes
end



