Rails.application.config.middleware.use OmniAuth::Builder do  
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
