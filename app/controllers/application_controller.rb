# coding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user
  private
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  rescue
    session[:user_id] = nil
  end
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
  def require_login
    unless current_user
      flash[:failure] = "Você precisa estar logado para realizar esta ação."
      redirect_to :root
      false
    else
      true
    end
  end
end
