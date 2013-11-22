module User::OmniauthHandler
  extend ActiveSupport::Concern

  included do
    def self.find_via_omniauth(omniauth, provider_name)
      joins(authorizations: [ :oauth_provider ]).
        where("authorizations.uid = :uid AND oauth_providers.name = :provider_name", { uid: omniauth[:uid], provider_name: provider_name }).first
    end

    def self.create_with_omniauth(auth, current_user = nil)

      auth_email = omniauth_email(auth)

      if current_user
        user = current_user
      elsif auth_email && user = find_by(email: auth_email)
      else
        user = build_with_omniauth_info(auth)
      end

      provider = OauthProvider.where(name: auth['provider']).first
      user.authorizations.create!(uid: auth['uid'], oauth_provider_id: provider.id) if provider

      user
    end

    private

    def self.build_with_omniauth_info(auth)
      create! do |user|
        user.name = auth["info"]["name"]
        user.email = omniauth_email(auth)
        user.nickname = auth["info"]["nickname"]
        user.bio = (auth["info"]["description"][0..139] rescue nil)
        user.locale = I18n.locale.to_s
        user.image_url = "https://graph.facebook.com/#{auth['uid']}/picture?type=large" if auth["provider"] == "facebook"
      end
    end

    def self.omniauth_email(auth)
      auth_email = (auth["info"]["email"] rescue nil)

      unless auth_email
        auth_email = (auth["extra"]["user_hash"]["email"] rescue nil)
      end

      auth_email
    end

  end
end
