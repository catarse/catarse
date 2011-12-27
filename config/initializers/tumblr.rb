require 'tumblr'
# Who the fuck removed the aweson refactoring in Configuration???
# user = Tumblr::User.new(*Configuration[:tumblr_email, :tumblr_password])
TumblrUser = Tumblr::User.new(Configuration.find_by_name('tumblr_user').value, Configuration.find_by_name('tumblr_password').value, false)
Tumblr.blog = 'blog.catarse.me'

class Tumblr
  class Request
    def self.read(options = {})
      response = HTTParty.get("http://#{Tumblr::blog}/api/read?#{options.to_params}", {})
      return response unless raise_errors(response)
    end
  end
end