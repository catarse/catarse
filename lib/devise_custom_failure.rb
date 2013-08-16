class DeviseCustomFailure < Devise::FailureApp
  def redirect_url
    new_user_registration_path
  end

  def respond
    http_auth? ? http_auth : redirect
  end
end
