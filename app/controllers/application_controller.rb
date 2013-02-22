# coding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::Unauthorized do |exception|
    session[:return_to] = request.env['REQUEST_URI']
    if current_user.nil?
      redirect_to new_user_session_path, alert: I18n.t('devise.failure.unauthenticated')
    elsif request.env["HTTP_REFERER"]
      redirect_to :back, alert: exception.message
    else
      redirect_to root_path, alert: exception.message
    end
  end

  helper_method :namespace,
                :fb_admins, :statistics, :render_facebook_sdk, :render_facebook_like,
                :render_twitter

  #before_filter :set_locale
  #before_filter :detect_locale

  before_filter :force_http

  # TODO: Change this way to get the opendata
  before_filter do
    @fb_admins = [567237711]
  end

  before_filter do
    if params[:newsletter].present?
      flash[:notice] = I18n.t('newsletter_ok_body') if params[:newsletter] == 'ok'
      flash[:alert] = I18n.t('newsletter_error_body') if params[:newsletter] == 'error'
    end
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

  private
  def statistics
    @statistics ||= Statistics.first
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
        return redirect_to params.merge(locale: new_locale)
      rescue ActionController::RoutingError 
        logger.info "Could not redirect with params #{params.inspect} in set_locale"
      end
    end
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

  def render_404
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end

  def force_http
    redirect_to(protocol: 'http', host: ::Configuration[:base_domain]) if request.ssl?
  end
end
