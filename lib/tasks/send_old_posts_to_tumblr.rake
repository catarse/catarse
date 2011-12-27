desc "Sends old posts (comments with project_update true) to tumblr"
task :send_old_posts_to_tumblr => :environment do

  class Tumblr
    class Request
      def self.write(options = {})
        response = HTTParty.post('http://www.tumblr.com/api/write', :body => options)
        return(response) unless raise_errors(response)
      end
    end
  end
  # Redefines the model
  class Comment < ActiveRecord::Base
    scope :posts, where("project_update")
    belongs_to :project, foreign_key: :commentable_id
  end

  user = Tumblr::User.new(Configuration.find_by_name('tumblr_user').value, Configuration.find_by_name('tumblr_password').value, false)
  Tumblr.blog = 'blog.catarse.me'
  Comment.posts.each do |post|
    Tumblr::Post.create(user, title: post.title, body: post.comment, date: post.created_at, :tags => post.project.to_param)

  end

end