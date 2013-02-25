class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :set_locale

  def facebook
    omniauth = request.env['omniauth.auth']
    @user = User.
      select('users.*').
      joins('JOIN authorizations ON authorizations.user_id = users.id').
      joins('JOIN oauth_providers ON oauth_providers.id = authorizations.oauth_provider_id').
      where("authorizations.uid = ? AND oauth_providers.name = 'facebook'", omniauth[:uid]).
      first || User.create_with_omniauth(omniauth)

    flash[:notice] = I18n.t("devise.omniauth_callbacks.success", :kind => "Facebook")
    sign_in @user, :event => :authentication
    if @user.email
      redirect_to(session[:return_to] || root_path)
      session[:return_to] = nil
    else
      render :set_email
    end
  end
end
