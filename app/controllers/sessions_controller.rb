# coding: utf-8
class SessionsController < ApplicationController

  skip_before_filter :detect_locale
  
  def auth
    session[:return_to] = params[:return_to]
    session[:remember_me] = params[:remember_me]
    redirect_to "/auth/#{params[:provider]}"
  end

  def create
    auth = request.env["omniauth.auth"]
    user = User.find_with_omni_auth(auth["provider"], auth["uid"].to_s)
    unless user
      user = User.create_with_omniauth(auth)
      if session[:return_to].nil? or session[:return_to].empty?
        session[:return_to] = user_path(user) 
      end
    end
    session[:user_id] = user.id
    if session[:remember_me]
      cookies[:remember_me_id] = { :value => user.id, :expires => 30.days.from_now }
      cookies[:remember_me_hash] = { :value => user.remember_me_hash, :expires => 30.days.from_now }
    end
    flash[:success] = t('sessions.auth.success', :name => user.display_name)
    redirect_back_or_default :root
  end

  def destroy
    session[:user_id] = nil
    cookies.delete :remember_me_id if cookies[:remember_me_id]
    cookies.delete :remember_me_hash if cookies[:remember_me_hash]
    flash[:success] = t('sessions.destroy.success')
    redirect_to :root
  end
  
  def failure
    flash[:failure] = t('sessions.failure.error')
    redirect_to :root
  end
  
  def fake_create
    raise "Forbiden" unless Rails.env == "test"
    user = Factory(:user, :uid => 'fake_login')
    session[:user_id] = user.id
    flash[:success] = t('sessions.post_auth.success', :name => user.display_name)
    redirect_to :root
  end
  
end
