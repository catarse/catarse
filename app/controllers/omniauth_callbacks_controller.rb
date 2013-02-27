class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :set_locale

  def facebook
    omniauth = request.env['omniauth.auth']
    @user = User.
      select('users.*').
      joins('JOIN authorizations ON authorizations.user_id = users.id').
      joins('JOIN oauth_providers ON oauth_providers.id = authorizations.oauth_provider_id').
      where("authorizations.uid = ? AND oauth_providers.name = 'facebook'", omniauth[:uid]).first

    if @user && @user.persisted?
      flash[:notice] = I18n.t("devise.omniauth_callbacks.success", :kind => "Facebook")
      sign_in @user, :event => :authentication
      redirect_to(session[:return_to] || root_path)
      session[:return_to] = nil
    else
      session[:omniauth] = omniauth.except('extra')
      redirect_to new_user_registration_url
    end
  end

  def google_oauth2
  omniauth = request.env['omniauth.auth']
  @user = User.find_for_google_oauth(request.env["omniauth.auth"], current_user)
  if @user && @user.persisted?
    flash[:notice] = I18n.t("devise.omniauth_callbacks.success", :kind => "Google")
    sign_in @user, :event => :authentication #this will throw if @user is not activated
    redirect_to(session[:return_to] || root_path)
    session[:return_to] = nil 
    #set_flash_message(:notice, :success, :kind => "Google") if is_navigational_format?
  else
    session[:omniauth] = omniauth.except('extra')
    #session["devise.oauth_data"] = request.env["omniauth.auth"]["info"]
    redirect_to new_user_registration_url
  end
end
end
