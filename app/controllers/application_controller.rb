# coding: utf-8
class ApplicationController < ActionController::Base
  include Concerns::ExceptionHandler
  include Concerns::MenuHandler
  include Concerns::SocialHelpersHandler
  include Concerns::AnalyticsHelpersHandler
  include Pundit

  layout 'catarse_bootstrap'
  protect_from_forgery

  before_filter :configure_permitted_parameters, if: :devise_controller?

  helper_method :referal_link, :render_projects, :should_show_beta_banner?, :render_feeds

  before_filter :set_locale

  before_action :referal_it!

  before_action :force_www

  def referal_link
    session[:referal_link]
  end

  def render_projects collection, ref, locals = {}
    render_to_string partial: 'projects/card', collection: collection, locals: {ref: ref}.merge!(locals)
  end

  def render_feeds collection, locals = {}
    render_to_string partial: 'users/feeds/feed', collection: collection, locals: locals
  end

  def should_show_beta_banner?
    current_user.nil? || current_user.projects.empty?
  end

  def should_show_beta_banner?
    current_user.nil? || current_user.projects.empty?
  end

  private
  def force_www
    if request.subdomain.blank? && Rails.env.production?
      return redirect_to url_for(params.merge(subdomain: 'www'))
    end
  end

  def referal_it!
    session[:referal_link] = params[:ref] if params[:ref].present?
  end

  def detect_old_browsers
    return redirect_to page_path("bad_browser") if (!browser.modern? || browser.ie9?) && controller_name != 'pages'
  end

  def set_locale
    if params[:locale]
      I18n.locale = params[:locale]
      current_user.try(:change_locale, params[:locale])
    elsif request.method == "GET"
      new_locale = current_user.try(:locale) || I18n.default_locale
      redirect_to url_for(params.merge(locale: new_locale, only_path: true))
    end
  end

  def after_sign_in_path_for(resource_or_scope)
    (session.delete(:return_to) || root_path)
  end

  def redirect_user_back_after_login
    if request.env['REQUEST_URI'].present? && !request.xhr?
      session[:return_to] = request.env['REQUEST_URI']
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:name, :email, :password, :newsletter)
    end
  end
end
