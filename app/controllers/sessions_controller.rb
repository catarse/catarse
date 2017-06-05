# frozen_string_literal: true

class SessionsController < Devise::SessionsController
  def new
    super
    session[:return_to] = params[:redirect_to] if params[:redirect_to].present?
  end

  def destroy_and_redirect
    sign_out current_user
    redirect_to new_project_contribution_path(project_id: params[:project_id].to_i)
  end
end
