# frozen_string_literal: true

class SessionsController < Devise::SessionsController
  def new
    if params[:return_to] && (
        params[:return_to].match?(/zendesk/) || 
        params[:return_to].match?(/suporte\.catarse/) )
      session[:zendesk_return] = params[:return_to]
    end

    super
    session[:return_to] = params[:redirect_to] if params[:redirect_to].present?
  end

  def after_sign_in_path_for(resource)
    if session[:zendesk_return]
      zlink = session[:zendesk_return].dup
      session[:zendesk_return] = nil
      zendesk_session_create_path(return_to: zlink)
    else
      super
    end
  end

  def destroy_and_redirect
    sign_out current_user
    if params[:project_id]
      redirect_to new_project_contribution_path(project_id: params[:project_id].to_i, locale: '')
    else
      redirect_to root_path
    end
  end
end
