module ActionDispatch
  class Request
    def flash
      session["flash"] = Flash::FlashHash.new if not session["flash"]
      @env['action_dispatch.request.flash_hash'] ||= session["flash"].tap(&:sweep)
    end
  end
end

# coding: utf-8
class ApplicationController < ActionController::Base

  protect_from_forgery

  helper_method :current_user, :replace_locale, :align_logo_when_home, :is_homepage?, :namespace,
                :fb_admins, :has_institutional_videos?, :institutional_video
  before_filter :set_locale
  before_filter :detect_locale

  # TODO: Change this way to get the opendata
  before_filter do
    @total_backers = User.backers.count
    @total_backs = Backer.confirmed.count
    @total_backed = Backer.confirmed.sum(:value)
    @total_users = User.primary.count
    @total_projects = Project.visible.count
    @total_projects_success = Project.successful.count
    @total_projects_online = Project.visible.not_expired.count
    @fb_admins = [567237711]
  end

  before_filter do
    if params[:newsletter].present?
      flash[:notice] = I18n.t('newsletter_ok_body') if params[:newsletter] == 'ok'
      flash[:alert] = I18n.t('newsletter_error_body') if params[:newsletter] == 'error'
    end
  end


  private

  def has_institutional_videos?
    InstitutionalVideo.visibles.present?
  end
  
  def institutional_video
    InstitutionalVideo.visibles.random.first
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
      return session[:user_id] = @current_user.id
    end
    return @current_user = request.env['warden'].authenticate(:user) rescue nil
  rescue Exception => e
    session[:user_id] = nil
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

  def require_condition(condition, message)
    unless condition
      flash[:failure] = message
      if current_user
        redirect_to root_path
      else
        session[:return_to] = request.env['REQUEST_URI']
        redirect_to login_path
        false
      end
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
