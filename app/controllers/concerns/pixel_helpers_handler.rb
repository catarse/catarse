# frozen_string_literal: true

module PixelHelpersHandler
  extend ActiveSupport::Concern

  included do
    helper_method :render_facebook_pixel_script

    def render_facebook_pixel_script
      render_to_string(partial: 'layouts/facebook_pixel').html_safe
    end

  end
end
