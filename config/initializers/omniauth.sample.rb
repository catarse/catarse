require 'openid/store/filesystem'
Rails.application.config.middleware.use OmniAuth::Builder do  
  # Put your auth keys here and copy to config/initializers/omniauth.rb before running catarse
  provider :twitter, '', ''  
  provider :open_id, OpenID::Store::Filesystem.new("#{Rails.root}/tmp"), :name => 'google', :identifier => 'https://www.google.com/accounts/o8/id'
  provider :github, '', ''  
  provider :facebook, '', ''  
end
