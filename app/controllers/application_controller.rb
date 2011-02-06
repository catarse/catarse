# coding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user
  private
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
    require_condition(current_user, "Você precisa estar logado para realizar esta ação.")
  end
  def require_admin
    require_condition((current_user and current_user.admin), "Você precisa ser admin para realizar esta ação.")
  end
end
