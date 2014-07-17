ZendeskEngine.configure do |config|
  config.url   = CatarseSettings[:zendesk_url] + "/api/v2"
  config.user  = CatarseSettings[:zendesk_user]
  config.token = CatarseSettings[:zendesk_token]
end
