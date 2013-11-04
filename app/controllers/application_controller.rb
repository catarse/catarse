# coding: utf-8
require 'uservoice_sso'
class ApplicationController < ActionController::Base
  layout :use_catarse_boostrap
  protect_from_forgery

  before_filter :redirect_user_back_after_login, unless: :devise_controller?
  before_filter :configure_permitted_parameters, if: :devise_controller?

  rescue_from ActionController::RoutingError, with: :render_404
  rescue_from ActionController::UnknownController, with: :render_404
  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  rescue_from CanCan::Unauthorized do |exception|
    session[:return_to] = request.env['REQUEST_URI']
    message = exception.message

    if current_user.nil?
      redirect_to new_user_registration_path, alert: I18n.t('devise.failure.unauthenticated')
    elsif request.env["HTTP_REFERER"]
      redirect_to :back, alert: message
    else
      redirect_to root_path, alert: message
    end
  end

  helper_method :channel, :namespace, :fb_admins, :render_facebook_sdk, :render_facebook_like, :render_twitter, :display_uservoice_sso

  before_filter :set_locale
  before_filter :force_http

  before_action :referal_it!

  # TODO: Change this way to get the opendata
  before_filter do
    @fb_admins = [100000428222603, 547955110]
  end

  @@menu_items = {}
  cattr_accessor :menu_items

  def self.add_to_menu i18n_name, path
    menu I18n.t(i18n_name) => path
  end

  def self.menu menu
    self.menu_items.merge! menu
  end

  def menu
    ApplicationController.menu_items.inject({}) do |memo, el|
      memo.merge!(el.first => Rails.application.routes.url_helpers.send(el.last)) if can? :access, el.last
      memo
    end
  end

  def channel
    Channel.find_by_permalink(request.subdomain.to_s)
  end

  # We use this method only to make stubing easier
  # and remove FB templates from acceptance tests
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

  private
  def referal_it!
    session[:referal_link] = params[:ref] if params[:ref].present?
  end

  def detect_old_browsers
    return redirect_to page_path("bad_browser") if (!browser.modern? || browser.ie9?) && controller_name != 'pages'
  end

  def fb_admins
    @fb_admins.join(',')
  end

  def fb_admins_add(ids)
    case ids.class
    when Array
      ids.each {|id| @fb_admins << ids.to_i}
    else
      @fb_admins << ids.to_i
    end
  end

  def namespace
    names = self.class.to_s.split('::')
    return "null" if names.length < 2
    names[0..(names.length-2)].map(&:downcase).join('_')
  end

  def set_locale
    if params[:locale]
      I18n.locale = params[:locale]
      current_user.update_attribute :locale, params[:locale] if current_user && params[:locale] != current_user.locale
    elsif request.method == "GET"
      new_locale = (current_user.locale if current_user) || I18n.default_locale
      begin
        return redirect_to params.merge(locale: new_locale, only_path: true)
      rescue ActionController::RoutingError
        logger.info "Could not redirect with params #{params.inspect} in set_locale"
      end
    end
  end

  def use_catarse_boostrap
    devise_controller? ? 'catarse_bootstrap' : 'application'
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def after_sign_in_path_for(resource_or_scope)
    return_to = session[:return_to]
    session[:return_to] = nil
    (return_to || root_path)
  end

  def render_404(exception)
    @not_found_path = exception.message
    respond_to do |format|
      format.html { render template: 'errors/not_found', layout: 'layouts/catarse_bootstrap', status: 404 }
      format.all { render nothing: true, status: 404 }
    end
  end

  def force_http
    redirect_to(protocol: 'http', host: ::Configuration[:base_domain]) if request.ssl?
  end

  def redirect_user_back_after_login
    if request.env['REQUEST_URI'].present? && !request.xhr?
      session[:return_to] = request.env['REQUEST_URI']
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:name,
                                                            :email,
                                                            :password, :newsletter) }
  end

  def current_ability
    @current_ability ||= Ability.new(current_user, { channel: channel })
  end
end
