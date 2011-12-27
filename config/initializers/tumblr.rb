require 'tumblr'

TumblrUser = Tumblr::User.new(*Configuration[:tumblr_user, :tumblr_password], false)
Tumblr.blog = 'blog.catarse.me'

class Tumblr
  class Request
    def self.read(options = {})
      response = HTTParty.get("http://#{Tumblr::blog}/api/read?#{options.to_params}", {})
      return response unless raise_errors(response)
    end
  end
end