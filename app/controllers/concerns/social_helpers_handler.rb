require 'uservoice_sso'
module Concerns
  module SocialHelpersHandler
    extend ActiveSupport::Concern

    # We use this method only to make stubing easier
    # and remove FB templates from acceptance tests
    included do
      helper_method :fb_admins, :render_facebook_sdk, :render_facebook_like, :render_twitter, :display_uservoice_sso

      before_filter do
        @fb_admins = [100000428222603, 547955110]
      end
    end

    def fb_admins
      @fb_admins.join(',')
    end

    def fb_admins_add(ids)
      if ids.kind_of?(Array)
        ids.each {|id| @fb_admins << id.to_i}
      else
        @fb_admins << ids.to_i
      end
    end

    def render_facebook_sdk
      render_to_string(partial: 'layouts/facebook_sdk').html_safe
    end

    def render_twitter options={}
      render_to_string(partial: 'layouts/twitter', locals: options).html_safe
    end

    def render_facebook_like options={}
      render_to_string(partial: 'layouts/facebook_like', locals: options).html_safe
    end

    def display_uservoice_sso
      if current_user && ::Configuration[:uservoice_subdomain] && ::Configuration[:uservoice_sso_key]
        Uservoice::Token.generate({
          guid: current_user.id, email: current_user.email, display_name: current_user.display_name,
          url: user_url(current_user), avatar_url: current_user.display_image
        })
      end
    end

  end
end
