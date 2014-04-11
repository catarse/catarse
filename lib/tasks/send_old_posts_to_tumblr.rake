desc "Sends old posts (comments with project_update true) to tumblr"
task :send_old_posts_to_tumblr => :environment do

  # Redefines the model
  class Comment < ActiveRecord::Base
    scope :posts, where("project_update")
    belongs_to :project, foreign_key: :commentable_id
  end

  Comment.posts.each do |post|
    Tumblr::Post.create(TumblrUser, group: CatarseSettings[:tumblr_blog], title: post.title, body: post.comment, date: post.created_at, tags: post.project.to_param)
  end

end
