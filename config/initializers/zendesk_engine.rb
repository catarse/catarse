ZendeskEngine.configure do |config|
  config.url   = CatarseSettings[:zendesk_api_url]
  config.user  = CatarseSettings[:zendesk_user]
  config.token = CatarseSettings[:zendesk_token]
end
