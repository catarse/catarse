class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user  
    
  private  
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  rescue
    session[:user_id] = nil
  end
end
