# frozen_string_literal: true

module Concerns
  module SocialHelpersHandler
    extend ActiveSupport::Concern

    # We use this method only to make stubing easier
    # and remove FB templates from acceptance tests
    included do
      helper_method :render_facebook_sdk, :render_facebook_like, :render_twitter, :render_twitter_mobile, :render_facebook_share, :render_facebook_share_mobile
    end

    def render_facebook_sdk
      render_to_string(partial: 'layouts/facebook_sdk').html_safe
    end

    def render_twitter(options = {})
      render_to_string(partial: 'layouts/twitter', locals: options).html_safe
    end

    def render_twitter_mobile(options = {})
      render_to_string(partial: 'layouts/twitter_mobile', locals: options).html_safe
    end

    def render_facebook_like(options = {})
      render_to_string(partial: 'layouts/facebook_like', locals: options).html_safe
    end

    def render_facebook_share(options = {})
      render_to_string(partial: 'layouts/facebook_share', locals: options).html_safe
    end

    def render_facebook_share_mobile(options = {})
      render(partial: 'layouts/facebook_share_mobile', locals: options)[0].html_safe
    end
  end
end
