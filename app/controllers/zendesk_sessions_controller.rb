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
                                  external_id: current_user.id.to_s,
                                  user_fields: {
                                    paid_count: current_user.contributions.where('contributions.was_confirmed').count,
                                    draft_count: current_user.projects.with_state(:draft).count,
                                    online_count: current_user.projects.with_state(:online).count,
                                    successful_count: current_user.projects.with_state(:successful).count,
                                    failed_count: current_user.projects.with_state(:failed).count,
                                    has_sub_project: current_user.projects.where(mode: :sub).count > 0,
                                    last_backed_project: current_user.contributions.last.try(:project).try(:permalink),
                                    has_subscription: Subscription.where(status: :active, user: current_user).present?,
                                    user_phone_number: current_user.address.try(:phone_number),
                                    last_message: DirectMessage.where(user: current_user).last.try(:content),
                                    pending_count: current_user.payments.where(state: 'pending').where("payments.created_at > current_timestamp - '7 days'::interval ").count
                                  }
                                }, key: CatarseSettings[:zendesk_shared_secret])

    redirect_to zendesk_sso_url(payload)
  end

  def zendesk_sso_url(payload)
    url = "#{CatarseSettings[:zendesk_access_url]}jwt?jwt=#{payload}"
    url += "&" + {return_to: params["return_to"]}.to_query if params["return_to"].present?
    url
  end
end
