module Concerns
  module AnchorSessions
    extend ActiveSupport::Concern

    included do
      helper_method :can_show_errors_on

      def can_show_errors_on anchor
        session[:show_errors_on_anchor] == anchor
      end

      def save_anchor_session_error
        if params[:anchor]
          session[:show_errors_on_anchor] = params[:anchor]
        else
          session.delete(:show_errors_on_anchor)
        end
      end
    end

  end
end

