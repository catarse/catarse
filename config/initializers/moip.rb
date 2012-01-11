MoIP.setup do |config|
  config.token = Configuration[:moip_token] or ''
  config.key = Configuration[:moip_key] or ''
end