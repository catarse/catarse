MoIP.setup do |config|
  begin
    config.token = Configuration.find_by_name('moip_token').value
    config.key = Configuration.find_by_name('moip_key').value
  rescue
    Configuration.create(:name => 'moip_token', :value => '')
    Configuration.create(:name => 'moip_key', :value => '')
    config.token = Configuration.find_by_name('moip_token').value
    config.key = Configuration.find_by_name('moip_key').value
  end
end
