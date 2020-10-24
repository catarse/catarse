# frozen_string_literal: true

module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActionController::RoutingError, with: :render_404
    rescue_from AbstractController::ActionNotFound, with: :render_404
    rescue_from ActiveRecord::RecordNotFound, with: :render_404

    rescue_from Pundit::NotAuthorizedError, with: :auth_error
  end

  def auth_error(exception)
    session[:return_to] = request.env['REQUEST_URI']

    if current_user.nil?
      redirect_to new_user_registration_path, alert: I18n.t('devise.failure.unauthenticated')
    else
      redirect_back(fallback_location: root_path)
    end
  end

  def render_404(exception)
    @not_found_path = exception.message
    respond_to do |format|
      format.html { render template: 'errors/not_found', layout: 'layouts/catarse_bootstrap', status: 404 }
      format.all { render body: nil, status: 404 }
    end
  end
end
