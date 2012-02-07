class PasswordsController < Devise::PasswordsController
  def create
    self.resource = resource_class.where(:provider => 'devise').send_reset_password_instructions(params[resource_name])

    if successfully_sent?(resource)
      respond_with({}, :location => after_sending_reset_password_instructions_path_for(resource_name))
    else
      flash[:failure] = resource.errors.full_messages.to_sentence
      redirect_to root_url(:show_forgot_password => true)
    end
  end
  
  protected
  
  # The path used after sending reset password instructions
  def after_sending_reset_password_instructions_path_for(resource_name)
    root_path
  end  
end