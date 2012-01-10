require 'tumblr'

TumblrUser = Tumblr::User.new(*Configuration[:tumblr_user, :tumblr_password], false)
Tumblr.blog = Configuration[:tumblr_blog]

# Monkeypacth the (crappy) gem.
class Tumblr
  class Post
    def self.find_every(opts)
      posts = Request.read({:num => 50}.merge(opts))['tumblr']['posts']['post']
      posts.is_a?(Array) ? posts : [posts]
    end
  end
  READ_URL = "http://%s/api/read"
  WRITE_URL = "http://www.tumblr.com/api/write"
  class Request
    def self.read(options = {})
      url = Tumblr::READ_URL%[Tumblr::blog]
      response = HTTParty.get(url, options)
      return response unless raise_errors(response)
    end
    def self.write(options = {})
      response = HTTParty.post(Tumblr::WRITE_URL, :body => options)
      return(response) unless raise_errors(response)
    end
  end
end