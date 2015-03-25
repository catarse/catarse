class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :set_locale

  def self.add_providers
    OauthProvider.all.each do |p|
      define_method p.name.downcase do
        omniauth = request.env['omniauth.auth']
        unless (@auth = Authorization.find_from_hash(omniauth))
          user = current_user || (User.find_by_email(omniauth[:info][:email]) if omniauth[:info][:email])
          @auth = Authorization.create_from_hash(omniauth, user)
        end

        flash[:notice] = I18n.t("devise.omniauth_callbacks.success", kind: p.name.capitalize)
        sign_in @auth.user, event: :authentication
        redirect_to after_sign_in_path_for(@auth.user)
      end
    end
  end
end
