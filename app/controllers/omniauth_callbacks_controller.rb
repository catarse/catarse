class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    omniauth = request.env['omniauth.auth']
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
