class SessionsController < Devise::SessionsController

  def new
    super
    if params[:redirect_to].present?
      session[:return_to] = params[:redirect_to]
    end
  end

  def destroy_and_redirect
    sign_out current_user
    redirect_to new_project_contribution_path(project_id: params[:project_id].to_i)
  end

end
