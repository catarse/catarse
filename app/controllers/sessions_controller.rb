class SessionsController < Devise::SessionsController

  def new
    super
    if params[:redirect_to].present?
      session[:return_to] = params[:redirect_to]
    end
  end

end
