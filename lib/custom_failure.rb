class CustomFailure < Devise::FailureApp
  def redirect_url
    root_url(:require_login=>true)
  end

  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end