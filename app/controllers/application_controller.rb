# coding: utf-8
class ApplicationController < ActionController::Base

  protect_from_forgery

  helper_method :current_user, :replace_locale, :align_logo_when_home, :is_homepage?
  before_filter :set_locale
  before_filter :detect_locale

  private

  def is_homepage?
    controller_name == 'projects' && action_name == 'index'
  end

  def align_logo_when_home
    'home_logo' if is_homepage?
  end

  def set_locale
    return unless params[:locale]
    I18n.locale = params[:locale]
    return unless current_user
    current_user.update_attribute :locale, params[:locale] if params[:locale] != current_user.locale
  end

  def detect_locale
    return unless request.method == "GET"
    return if params[:locale]
    new_locale = current_user.locale if current_user
    new_locale = session[:locale] if session[:locale]
    unless new_locale
      new_locale = request.compatible_language_from(I18n.available_locales.map(&:to_s))
      new_locale = I18n.default_locale.to_s unless new_locale
      flash[:locale] = t('notify_locale', :locale => new_locale)
    end
    return redirect_to replace_locale(new_locale)
  end

  def replace_locale(new_locale)
    session[:locale] = new_locale
    new_url = "#{request.fullpath}"
    if params[:locale]
      new_url.gsub!(/^\/#{params[:locale]}/, "/#{new_locale}")
    else
      if new_url == "/"
        new_url = "/#{new_locale}"
      else
        new_url[0] = "/#{new_locale}/"
      end
    end
    new_url
  end

  def current_user
    return @current_user if @current_user
    if session[:user_id]
      return @current_user = User.find(session[:user_id])
    end
    if cookies[:remember_me_id] and cookies[:remember_me_hash]
      @current_user = User.find(cookies[:remember_me_id])
      @current_user = nil unless @current_user.remember_me_hash == cookies[:remember_me_hash]
      session[:user_id] = @current_user.id
    end
  rescue
    session[:user_id] = nil
  end
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
  def require_condition(condition, message)
    unless condition
      flash[:failure] = message
      redirect_to :root
      false
    else
      true
    end
  end
  def require_login
    require_condition(current_user, t('require_login'))
  end
  def require_admin
    require_condition((current_user and current_user.admin), t('require_admin'))
  end
  def render_404
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end
end
