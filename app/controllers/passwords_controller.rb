class PasswordsController < Devise::PasswordsController

  prepend_before_filter :redirect_user_already_logged, only: [:edit]

  def update
    self.resource = resource_class.reset_password_by_token(resource_params)

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
      set_flash_message(:notice, flash_message) if is_navigational_format?
      sign_in(resource_name, resource)
      respond_with resource, location: after_resetting_password_path_for(resource)
    else
      if resource.errors[:password]
        return respond_with resource
      end

      flash[:notice] = I18n.t('devise.failure.password_token')
      redirect_to new_password_path(resource_name)
    end
  end

  protected
  def redirect_user_already_logged
    session[:return_to] = user_path(current_user, anchor: 'settings') if current_user.present?
  end

  def after_sending_reset_password_instructions_path_for(resource)
    new_password_path(resource_name)
  end
end
