# coding: utf-8
class SessionsController < ApplicationController
  def pre_auth
    session[:return_to] = params[:return_to]
    session[:remember_me] = params[:remember_me]
    redirect_to "http://catarse.me/auth/?provider=#{params[:provider]}&return_site_id=#{params[:return_site_id]}&return_session_id=#{session[:session_id]}"
  end
  def auth
    session[:return_site_id] = params[:return_site_id]
    session[:return_session_id] = params[:return_session_id]
    redirect_to "/auth/#{params[:provider]}"
  end
  def create
    auth = request.env["omniauth.auth"]
    user = User.find_with_omni_auth(auth["provider"], auth["uid"].to_s)
    new_user = false
    unless user
      user = User.create_with_omniauth(current_site, auth)
      new_user = true
    end
    user.update_attribute :session_id, session[:return_session_id]
    redirect_url = "/post_auth/?user_id=#{user.id}&new_user=#{new_user}"
    if session[:return_site_id] and session[:return_site_id].to_s != current_site.id.to_s
      site = Site.find(session[:return_site_id])
      redirect_url = "http://#{site.host}#{redirect_url}"
    end
    session[:return_site_id] = nil
    session[:return_session_id] = nil
    redirect_to redirect_url
  end
  def post_auth
    user = User.find(params[:user_id])
    if user.session_id != session[:session_id]
      flash[:failure] = "Ocorreu um erro ao realizar o login. Por favor, tente novamente."
      return redirect_to :root
    end
    if params[:new_user] == "true"
      session[:return_to] = user_path(user) if session[:return_to].nil? or session[:return_to].empty?
    end
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

