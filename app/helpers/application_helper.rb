# application_helper.rb
module ApplicationHelper
  def authorization_path(provider)
    "/auth/#{provider.to_s}"
  end
end