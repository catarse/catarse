class RegistrationsController < Devise::RegistrationsController
  def new
    redirect_to login_path(active_register: true)
  end

  def edit
    redirect_to user_path(current_user)
  end

  def create
    build_resource
    resource.provider = 'devise'
    resource.uid = Devise.friendly_token
    if resource.save

      if resource.newsletter and resource.email.present?
        begin
          api = Mailchimp::API.new(Configuration[:mailchimp_api_key])
          api.list_batch_subscribe({ :id => Configuration[:mailchimp_list_id], :batch => [ { :EMAIL => resource.email } ]  })
        rescue Exception => e
          Airbrake.notify({ :error_class => "MailChimp Error", :error_message => "MailChimp Error: #{e.inspect}", :parameters => params}) rescue nil
          Rails.logger.info "-----> #{e.inspect}"
        end
      end

      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)
        respond_with resource, :location => after_sign_in_path_for(resource)
      else
        set_flash_message :notice, :inactive_signed_up, :reason => resource.inactive_message.to_s if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords(resource)
      flash[:failure] = resource.errors.full_messages.to_sentence
      redirect_to login_url(active_register: true)
      # respond_with_navigational(resource) { render_with_scope :new }
    end
  end

  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)

    # If the user has filled in any of the password fields, we'll update their password
    any_passwords = %w(password password_confirmation current_password).any? do |field|
      params[resource_name][field].present?
    end
    update_method = any_passwords ? :update_with_password : :update_without_password

    if resource.send(update_method, params[resource_name])
      set_flash_message :notice, :updated if is_navigational_format?
      sign_in resource_name, resource, :bypass => true
      respond_with resource, :location => user_path(resource)
    else
      clean_up_passwords(resource)
      # respond_with_navigational(resource){ render_with_scope :edit }
      flash[:failure] = 'Ocorreu um erro ao tentar trocar sua senha.'
      redirect_to user_path(resource)
      # respond_with resource, :location => user_path(resource)
    end
  end
end
