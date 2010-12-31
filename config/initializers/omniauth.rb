require 'openid/store/filesystem'
Rails.application.config.middleware.use OmniAuth::Builder do  
  provider :open_id, OpenID::Store::Filesystem.new("#{Rails.root}/tmp"), :name => 'google', :identifier => 'https://www.google.com/accounts/o8/id'
  begin
    OauthProvider.all.each do |p|
      provider p.name.to_sym, p.key, p.secret
    end
  rescue Exception => e
    # We should initialize even with errors during providers setup
    Rails.logger.error "Error while setting omniauth providers: #{e.inspect}"
  end
end
