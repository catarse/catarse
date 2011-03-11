MoIP.setup do |config|
  config.token = Configuration.find_by_name('moip_token').value
  config.key = Configuration.find_by_name('moip_key').value
end
