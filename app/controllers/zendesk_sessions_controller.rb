require 'securerandom' unless defined?(SecureRandom)

class ZendeskSessionsController < ApplicationController
  before_action :authenticate_user!

  def create
    sign_into_zendesk
  end

  private

  def sign_into_zendesk
    # This is the meat of the business, set up the parameters you wish
    # to forward to Zendesk. All parameters are documented in this page.
    iat = Time.now.to_i
    jti = "#{iat}/#{SecureRandom.hex(18)}"

    payload = JsonWebToken.sign({
      iat: iat,
      jti: jti,
      name: current_user.display_name,
      email: current_user.email,
      external_id: current_user.id.to_s
    }, key: CatarseSettings[:zendesk_shared_secret])

    redirect_to zendesk_sso_url(payload)
  end

  def zendesk_sso_url(payload)
    url = "#{CatarseSettings[:zendesk_access_url]}jwt?jwt=#{payload}"
    url += "&" + {return_to: params["return_to"]}.to_query if params["return_to"].present?
    url
  end
end
