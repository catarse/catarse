require 'openid/store/filesystem'
Rails.application.config.middleware.use OmniAuth::Builder do  
  provider :open_id, OpenID::Store::Filesystem.new("#{Rails.root}/tmp"), :name => 'google', :identifier => 'https://www.google.com/accounts/o8/id'
  OauthProvider.all.each do |p|
    provider p.name.to_sym, p.key, p.secret
  end
end
