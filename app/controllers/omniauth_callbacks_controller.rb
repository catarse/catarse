class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :set_locale

  def facebook
    omniauth = request.env['omniauth.auth']
    raise omniauth.inspect
    @user = User.find_for_facebook_oauth(omniauth.uid, current_user)

    if @user and @user.persisted?
      flash[:notice] = I18n.t("devise.omniauth_callbacks.success", :kind => "Facebook")
      sign_in @user, :event => :authentication
      redirect_to(session[:return_to] || root_path)
      session[:return_to] = nil
    else
      session[:omniauth] = omniauth.except('extra')
      redirect_to new_user_registration_url
    end
  end
end
