# frozen_string_literal: true

require 'active_support/concern'

module Users::OmniauthHandler
  extend ActiveSupport::Concern

  included do
    def self.create_from_hash(hash)
      create!(
        {
          public_name: hash['info']['name'],
          name: hash['info']['name'],
          email: hash['info']['email'],
          about_html: begin
            hash['info']['description'][0..139]
          rescue
            nil
          end,
          locale: I18n.locale.to_s
        }
      ) do |user|
        case hash['provider']
        when 'facebook'
          user.remote_uploaded_image_url = "https://graph.facebook.com/v9.0/#{hash['uid']}/picture?type=large"
        when 'google_oauth2'
          user.remote_uploaded_image_url = hash['info']['image']
        end
      end
    end

    def has_facebook_authentication?
      oauth = OauthProvider.find_by_name 'facebook'
      authorizations.where(oauth_provider_id: oauth.id).present? if oauth
    end

    def facebook_id
      auth = authorizations.joins(:oauth_provider).where("oauth_providers.name = 'facebook'").first
      auth&.uid
    end

    def has_google_oauth2_authentication?
      oauth = OauthProvider.find_by_name 'google_oauth2'
      authorizations.where(oauth_provider_id: oauth.id).present? if oauth
    end

    def google_oauth2_id
      auth = authorizations.joins(:oauth_provider).where("oauth_providers.name = 'google_oauth2'").first
      auth&.uid
    end
  end
end
