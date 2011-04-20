# coding: utf-8
class SessionsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:auth]
  def auth
    session[:return_to] = params[:return_to]
    session[:return_site_id] = params[:return_site_id]
    session[:remember_me] = params[:remember_me]
    redirect_to "/auth/#{params[:provider]}"
  end
  def create
    auth = request.env["omniauth.auth"]
    user = User.find_with_omni_auth(auth["provider"], auth["uid"].to_s)
    unless user
      user = User.create_with_omniauth(current_site, auth, session[:old_user_id])
      session[:return_to] = user_path(user) if session[:return_to] and session[:return_to].empty?
    end
    session[:old_user_id] = nil
    session[:user_id] = user.id
    if session[:remember_me]
      cookies[:remember_me_id] = { :value => user.id, :expires => 30.days.from_now }
      cookies[:remember_me_hash] = { :value => user.remember_me_hash, :expires => 30.days.from_now }
    end
    flash[:success] = "Login realizado com sucesso. Bem-vindo, #{user.display_name}!"
    redirect_back_or_default :root
  end
  def destroy
    session[:user_id] = nil
    cookies.delete :remember_me_id if cookies[:remember_me_id]
    cookies.delete :remember_me_hash if cookies[:remember_me_hash]
    flash[:success] = "Logout realizado com sucesso. Até logo!"
    redirect_to :root
  end
  def failure
    flash[:failure] = "Ocorreu um erro ao realizar o login. Por favor, tente novamente."
    redirect_to :root
  end
  def fake_create
    raise "Forbiden" unless Rails.env == "test"
    user = Factory(:user, :uid => 'fake_login')
    session[:user_id] = user.id
    flash[:success] = "Login realizado com sucesso. Bem-vindo, #{user.display_name}!"
    redirect_to :root
  end
end

