MoIP.setup do |config|
  # TODO remove this line when we're ready to go to production
  config.uri = 'https://desenvolvedor.moip.com.br/sandbox'
  config.token = Configuration.find_by_name('moip_token').value
  config.key = Configuration.find_by_name('moip_key').value
end

