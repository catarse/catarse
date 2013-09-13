class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :set_locale

  def self.add_providers
    OauthProvider.all.each do |p|
      define_method p.name.downcase do
        omniauth = request.env['omniauth.auth']
        @user = User.
          select('users.*').
          joins('JOIN authorizations ON authorizations.user_id = users.id').
          joins('JOIN oauth_providers ON oauth_providers.id = authorizations.oauth_provider_id').
          where("authorizations.uid = :uid AND oauth_providers.name = :provider", {uid: omniauth[:uid], provider: p.name}).
          first || User.create_with_omniauth(omniauth, current_user)

        flash[:notice] = I18n.t("devise.omniauth_callbacks.success", kind: p.name.capitalize)
        sign_in @user, event: :authentication
        if @user.email
          redirect_to(session[:return_to] || root_path)
          session[:return_to] = nil
        else
          render 'users/set_email'
        end

      end
    end
  end
end
