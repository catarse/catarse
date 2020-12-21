# frozen_string_literal: true

module AnalyticsHelpersHandler
  extend ActiveSupport::Concern

  included do
    helper_method :render_google_analytics_script

    def render_google_analytics_script
      render_to_string(partial: 'layouts/analytics').html_safe
    end
  end
end
