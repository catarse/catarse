# coding: utf-8
class SessionsController < ApplicationController
  def auth
    session[:return_to] = params[:return_to]
    redirect_to "/auth/#{params[:provider]}"
  end
  def create
    auth = request.env["omniauth.auth"]
    user = User.find_by_provider_and_uid(auth["provider"], auth["uid"].to_s) || User.create_with_omniauth(auth)
    session[:user_id] = user.id
    flash[:success] = "Login realizado com sucesso. Bem-vindo, #{user.display_name}!"
    redirect_back_or_default :root
  end
  def destroy
    session[:user_id] = nil
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
