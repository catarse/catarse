module Concerns
  module AnalyticsHelpersHandler
    extend ActiveSupport::Concern

    included do
      helper_method :render_google_analytics_script, :render_mixpanel_script

      def render_google_analytics_script
        partial_name =  if channel && channel.ga_code
                          'layouts/channel_analytics'
                        else
                          'layouts/analytics'
                        end

        render_to_string(partial: partial_name).html_safe
      end

      def render_mixpanel_script
        render_to_string(partial: 'layouts/mixpanel').html_safe
      end
    end
  end
end
