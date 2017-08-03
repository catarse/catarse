# frozen_string_literal: true

class SessionsController < Devise::SessionsController
  def new
    super
    session[:return_to] = params[:redirect_to] if params[:redirect_to].present?
  end

  def destroy_and_redirect
    sign_out current_user
    if params[:project_id]
      url_params = {project_id: params[:project_id].to_i, locale: ''}
      url_params[:reward_id] = params[:reward_id].to_i if params[:reward_id] && params[:reward_id] != 'null'
      url_params[:value] = params[:value] if params[:value]
      redirect_to new_project_contribution_path(url_params)
    else
      redirect_to root_path
    end
  end

  def require_no_authentication
    set_zendesk_session
    super
  end

  def set_zendesk_session
    if params[:return_to] && (
        params[:return_to].match?(/zendesk/) || 
        params[:return_to].match?(/suporte\.catarse/) )
      session[:zendesk_return] = params[:return_to]
    end
  end
end
