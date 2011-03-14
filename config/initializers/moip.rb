MoIP.setup do |config|
  begin
    config.token = Configuration.find_by_name('moip_token').value
    config.key = Configuration.find_by_name('moip_key').value
  rescue
    config.token = ''
    config.key = ''
  end
end
