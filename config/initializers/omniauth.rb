require 'omniauth-openid'
require 'openid/store/filesystem'

Rails.application.config.middleware.use OmniAuth::Builder do  
  use OmniAuth::Strategies::OpenID, :store => OpenID::Store::Filesystem.new("#{Rails.root}/tmp")

  provider :open_id, :name => 'google', :identifier => 'https://www.google.com/accounts/o8/id'
  provider :open_id, :name => 'yahoo', :identifier => 'yahoo.com'
  #provider :facebook, ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'], {:client_options => {:ssl => {:ca_path => "/etc/ssl/certs"}}, :scope => 'publish_stream,email'}
  provider :stripe_connect, Configuration['stripe_client_id'], Configuration['stripe_secret_key'], {:scope => 'read_write', :stripe_landing => 'register'}
  #provider :linkedin, SETTINGS[:linkedin][:api_key], SETTINGS[:linkedin][:secret_key]
    
  #provider :wepay, SETTINGS['wepay_client_id'], SETTINGS['wepay_client_secret']
  
  #Twitter.configure do |config|
      #config.consumer_key = Configuration[:twitter][:consumer_key]
      #config.consumer_secret = Configuration[:twitter][:consumer_secret]
  #end
  begin
    OauthProvider.all.each do |p|
      # This hack can be removed after the upgrade to omniauth 2.0
      # Where every provider will accept the options hash
      unless p.scope.nil?
        provider p.strategy, p.key, p.secret, {:scope => p.scope}
      else
        provider p.strategy, p.key, p.secret
      end
    end
  rescue Exception => e
    # We should initialize even with errors during providers setup
    Rails.logger.error "Error while setting omniauth providers: #{e.inspect}"
  end
end
